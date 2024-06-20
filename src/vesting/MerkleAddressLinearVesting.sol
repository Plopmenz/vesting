// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VestingUtils} from "./VestingUtils.sol";
import {MerkleProof} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

library MerkleAddressLinearVestingStorage {
    bytes32 private constant SLOT = keccak256("merkle.address.linear.vesting.plopmenz");

    struct Storage {
        uint128 amount;
        uint64 start;
        uint64 duration;
        bytes32 merkletreeRoot;
        mapping(address account => uint128) released;
    }

    function getStorage() internal pure returns (Storage storage $) {
        bytes32 slot = SLOT;
        assembly {
            $.slot := slot
        }
    }
}

abstract contract MerkleAddressLinearVesting {
    error InvalidProof(bytes32[] proof, address account);

    function __MerkleAddressLinearVesting_init(
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        bytes32 _merkletreeRoot
    ) internal {
        MerkleAddressLinearVestingStorage.Storage storage $ = MerkleAddressLinearVestingStorage.getStorage();
        $.amount = _amount;
        $.start = _start;
        $.duration = _duration;
        $.merkletreeRoot = _merkletreeRoot;
    }

    function amount() external view returns (uint128) {
        MerkleAddressLinearVestingStorage.Storage storage $ = MerkleAddressLinearVestingStorage.getStorage();
        return $.amount;
    }

    function start() external view returns (uint64) {
        MerkleAddressLinearVestingStorage.Storage storage $ = MerkleAddressLinearVestingStorage.getStorage();
        return $.start;
    }

    function duration() external view returns (uint64) {
        MerkleAddressLinearVestingStorage.Storage storage $ = MerkleAddressLinearVestingStorage.getStorage();
        return $.duration;
    }

    function merkletreeRoot() external view returns (bytes32) {
        MerkleAddressLinearVestingStorage.Storage storage $ = MerkleAddressLinearVestingStorage.getStorage();
        return $.merkletreeRoot;
    }

    function released(address _account) external view returns (uint128) {
        MerkleAddressLinearVestingStorage.Storage storage $ = MerkleAddressLinearVestingStorage.getStorage();
        return $.released[_account];
    }

    function reward(address _beneficiary, uint128 _amount) internal virtual;

    /// @notice Getter for the address that will receive the tokens.
    function beneficiary(address _account) public view virtual returns (address);

    /// @notice Getter for the amount of releasable tokens.
    function releasable(address _account) public view virtual returns (uint128) {
        MerkleAddressLinearVestingStorage.Storage storage $ = MerkleAddressLinearVestingStorage.getStorage();
        return uint128(VestingUtils.linearVesting($.start, $.duration, $.amount, uint64(block.timestamp)))
            - $.released[_account];
    }

    /// @notice Release the tokens that have already vested.
    function release(bytes32[] memory _proof, address _account) public virtual {
        if (!verifyAddress(_proof, _account)) {
            revert InvalidProof(_proof, _account);
        }

        MerkleAddressLinearVestingStorage.Storage storage $ = MerkleAddressLinearVestingStorage.getStorage();
        address releaseBeneficiary = beneficiary(_account);
        uint128 releaseAmount = releasable(_account);
        $.released[_account] += releaseAmount;
        reward(releaseBeneficiary, releaseAmount);
    }

    function verifyAddress(bytes32[] memory _proof, address _account) public view returns (bool valid) {
        MerkleAddressLinearVestingStorage.Storage storage $ = MerkleAddressLinearVestingStorage.getStorage();
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account))));
        return MerkleProof.verify(_proof, $.merkletreeRoot, leaf);
    }
}
