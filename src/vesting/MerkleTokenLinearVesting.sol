// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VestingUtils} from "./VestingUtils.sol";
import {MerkleProof} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

abstract contract MerkleTokenLinearVesting {
    error InvalidProof(bytes32[] proof, uint256 tokenId);

    uint96 public immutable amount;
    uint64 public immutable start;
    uint64 public immutable duration;
    bytes32 public immutable merkletreeRoot;

    mapping(uint256 tokenId => uint96) public released;

    constructor(uint96 _amount, uint64 _start, uint64 _duration, bytes32 _merkletreeRoot) {
        amount = _amount;
        start = _start;
        duration = _duration;
        merkletreeRoot = _merkletreeRoot;
    }

    function reward(address _beneficiary, uint96 _amount) internal virtual;

    /// @notice Getter for the address that will receive the tokens.
    function beneficiary(uint256 _tokenId) public view virtual returns (address);

    /// @notice Getter for the amount of releasable tokens.
    function releasable(uint256 _tokenId) public view virtual returns (uint96) {
        return VestingUtils.linearVesting(start, duration, amount, uint64(block.timestamp)) - released[_tokenId];
    }

    /// @notice Release the tokens that have already vested.
    function release(bytes32[] memory _proof, uint256 _tokenId) public virtual {
        if (!verifyTokenid(_proof, _tokenId)) {
            revert InvalidProof(_proof, _tokenId);
        }

        address releaseBeneficiary = beneficiary(_tokenId);
        uint96 releaseAmount = releasable(_tokenId);
        released[_tokenId] += releaseAmount;
        reward(releaseBeneficiary, releaseAmount);
    }

    function verifyTokenid(bytes32[] memory _proof, uint256 _tokenId) public view returns (bool valid) {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_tokenId))));
        return MerkleProof.verify(_proof, merkletreeRoot, leaf);
    }
}
