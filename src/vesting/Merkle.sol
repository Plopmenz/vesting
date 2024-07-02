// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MerkleProof} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

import {MerkleStorage} from "../storage/MerkleStorage.sol";

abstract contract Merkle {
    event MerkleCreated(bytes32 merkletreeRoot);

    function __Merkle_init(bytes32 _merkletreeRoot) internal {
        emit MerkleCreated(_merkletreeRoot);
        MerkleStorage.Storage storage $ = MerkleStorage.getStorage();
        $.merkletreeRoot = _merkletreeRoot;
    }

    function merkletreeRoot() public view virtual returns (bytes32) {
        MerkleStorage.Storage storage $ = MerkleStorage.getStorage();
        return $.merkletreeRoot;
    }
}
