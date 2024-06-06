// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VestingUtils} from "./VestingUtils.sol";
import {MerkleProof} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

abstract contract MerkleAddressLinearVesting {
    error InvalidProof(bytes32[] proof, address account);

    uint96 public immutable amount;
    uint64 public immutable start;
    uint64 public immutable duration;
    bytes32 public immutable merkletreeRoot;

    mapping(address account => uint96) public released;

    constructor(uint96 _amount, uint64 _start, uint64 _duration, bytes32 _merkletreeRoot) {
        amount = _amount;
        start = _start;
        duration = _duration;
        merkletreeRoot = _merkletreeRoot;
    }

    function reward(address _beneficiary, uint96 _amount) internal virtual;

    /// @notice Getter for the address that will receive the tokens.
    function beneficiary(address _account) public view virtual returns (address);

    /// @notice Getter for the amount of releasable tokens.
    function releasable(address _account) public view virtual returns (uint96) {
        return VestingUtils.linearVesting(start, duration, amount, uint64(block.timestamp)) - released[_account];
    }

    /// @notice Release the tokens that have already vested.
    function release(bytes32[] memory _proof, address _account) public virtual {
        if (!verifyAddress(_proof, _account)) {
            revert InvalidProof(_proof, _account);
        }

        address releaseBeneficiary = beneficiary(_account);
        uint96 releaseAmount = releasable(_account);
        released[_account] += releaseAmount;
        reward(releaseBeneficiary, releaseAmount);
    }

    function verifyAddress(bytes32[] memory _proof, address _account) public view returns (bool valid) {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account))));
        return MerkleProof.verify(_proof, merkletreeRoot, leaf);
    }
}
