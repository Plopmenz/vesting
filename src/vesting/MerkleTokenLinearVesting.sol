// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VestingUtils} from "./VestingUtils.sol";
import {MerkleProof} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

library MerkleTokenLinearVestingStorage {
    bytes32 private constant SLOT = keccak256("merkle.token.linear.vesting.plopmenz");

    struct Storage {
        uint128 amount;
        uint64 start;
        uint64 duration;
        bytes32 merkletreeRoot;
        mapping(uint256 tokenId => uint128) released;
    }

    function getStorage() internal pure returns (Storage storage $) {
        bytes32 slot = SLOT;
        assembly {
            $.slot := slot
        }
    }
}

abstract contract MerkleTokenLinearVesting {
    error InvalidProof(bytes32[] proof, uint256 tokenId);

    function __MerkleTokenLinearVesting_init(uint128 _amount, uint64 _start, uint64 _duration, bytes32 _merkletreeRoot)
        internal
    {
        MerkleTokenLinearVestingStorage.Storage storage $ = MerkleTokenLinearVestingStorage.getStorage();
        $.amount = _amount;
        $.start = _start;
        $.duration = _duration;
        $.merkletreeRoot = _merkletreeRoot;
    }

    function amount() external view returns (uint128) {
        MerkleTokenLinearVestingStorage.Storage storage $ = MerkleTokenLinearVestingStorage.getStorage();
        return $.amount;
    }

    function start() external view returns (uint64) {
        MerkleTokenLinearVestingStorage.Storage storage $ = MerkleTokenLinearVestingStorage.getStorage();
        return $.start;
    }

    function duration() external view returns (uint64) {
        MerkleTokenLinearVestingStorage.Storage storage $ = MerkleTokenLinearVestingStorage.getStorage();
        return $.duration;
    }

    function merkletreeRoot() external view returns (bytes32) {
        MerkleTokenLinearVestingStorage.Storage storage $ = MerkleTokenLinearVestingStorage.getStorage();
        return $.merkletreeRoot;
    }

    function released(uint256 _tokenId) external view returns (uint128) {
        MerkleTokenLinearVestingStorage.Storage storage $ = MerkleTokenLinearVestingStorage.getStorage();
        return $.released[_tokenId];
    }

    function reward(address _beneficiary, uint128 _amount) internal virtual;

    /// @notice Getter for the address that will receive the tokens.
    function beneficiary(uint256 _tokenId) public view virtual returns (address);

    /// @notice Getter for the amount of releasable tokens.
    function releasable(uint256 _tokenId) public view virtual returns (uint128) {
        MerkleTokenLinearVestingStorage.Storage storage $ = MerkleTokenLinearVestingStorage.getStorage();
        return uint128(VestingUtils.linearVesting($.start, $.duration, $.amount, uint64(block.timestamp)))
            - $.released[_tokenId];
    }

    /// @notice Release the tokens that have already vested.
    function release(bytes32[] memory _proof, uint256 _tokenId) public virtual {
        if (!verifyTokenId(_proof, _tokenId)) {
            revert InvalidProof(_proof, _tokenId);
        }

        MerkleTokenLinearVestingStorage.Storage storage $ = MerkleTokenLinearVestingStorage.getStorage();
        address releaseBeneficiary = beneficiary(_tokenId);
        uint128 releaseAmount = releasable(_tokenId);
        $.released[_tokenId] += releaseAmount;
        reward(releaseBeneficiary, releaseAmount);
    }

    function verifyTokenId(bytes32[] memory _proof, uint256 _tokenId) public view returns (bool valid) {
        MerkleTokenLinearVestingStorage.Storage storage $ = MerkleTokenLinearVestingStorage.getStorage();
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_tokenId))));
        return MerkleProof.verify(_proof, $.merkletreeRoot, leaf);
    }
}
