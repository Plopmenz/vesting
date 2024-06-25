// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Merkle, MerkleProof} from "../Merkle.sol";
import {AddressReleased} from "../AddressReleased.sol";
import {LinearVesting} from "../LinearVesting.sol";

abstract contract MerkleAddressLinearVesting is Merkle, AddressReleased, LinearVesting {
    error InvalidProof(bytes32[] proof, address account);

    function __MerkleAddressLinearVesting_init(
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        bytes32 _merkletreeRoot
    ) internal {
        __Merkle_init(_merkletreeRoot);
        __AddressReleased_init();
        __LinearVesting_init(_amount, _start, _duration);
    }

    function release(bytes32[] memory _proof, address _account) public virtual {
        if (!verifyAddress(_proof, _account)) {
            revert InvalidProof(_proof, _account);
        }

        _release(_account);
    }

    function verifyAddress(bytes32[] memory _proof, address _account) public view returns (bool valid) {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account))));
        return MerkleProof.verify(_proof, merkletreeRoot(), leaf);
    }
}
