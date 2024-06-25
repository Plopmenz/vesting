// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library MerkleStorage {
    // keccak256(abi.encode(uint256(keccak256("merkle.vesting.plopmenz")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SLOT = 0x74be80346bcea2dc9d6300f0f2049b2134af2f9d0c227baac19ff2498c2aa200;

    /// @custom:storage-location erc7201:merkle.vesting.plopmenz
    struct Storage {
        bytes32 merkletreeRoot;
    }

    function getStorage() internal pure returns (Storage storage $) {
        assembly {
            $.slot := SLOT
        }
    }
}
