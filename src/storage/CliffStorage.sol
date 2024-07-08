// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library CliffStorage {
    // keccak256(abi.encode(uint256(keccak256("cliff.vesting.plopmenz")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SLOT = 0x31693d6d00188b327cd3ca4c0c119ed87e5ce23375744e9439ca34bd559d7800;

    /// @custom:storage-location erc7201:cliff.vesting.plopmenz
    struct Storage {
        uint64 cliff;
    }

    function getStorage() internal pure returns (Storage storage $) {
        assembly {
            $.slot := SLOT
        }
    }
}
