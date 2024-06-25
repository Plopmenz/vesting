// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Merkle, MerkleProof} from "../Merkle.sol";
import {TokenReleased} from "../TokenReleased.sol";
import {LinearVesting} from "../LinearVesting.sol";

abstract contract MerkleTokenLinearVesting is Merkle, TokenReleased, LinearVesting {
    error InvalidProof(bytes32[] proof, uint256 tokenId);

    function __MerkleTokenLinearVesting_init(uint128 _amount, uint64 _start, uint64 _duration, bytes32 _merkletreeRoot)
        internal
    {
        __Merkle_init(_merkletreeRoot);
        __TokenReleased_init();
        __LinearVesting_init(_amount, _start, _duration);
    }

    function release(bytes32[] memory _proof, uint256 _tokenId) public virtual {
        if (!verifyTokenId(_proof, _tokenId)) {
            revert InvalidProof(_proof, _tokenId);
        }

        _release(_tokenId);
    }

    function verifyTokenId(bytes32[] memory _proof, uint256 _tokenId) public view returns (bool valid) {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_tokenId))));
        return MerkleProof.verify(_proof, merkletreeRoot(), leaf);
    }
}
