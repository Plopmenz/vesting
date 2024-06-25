// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ManagerStorage {
    // keccak256(abi.encode(uint256(keccak256("manager.vesting.plopmenz")) - 1)) & ~bytes32(uint256(0xff))
    // bytes32 private constant SLOT = 0x9bd030a8ec256b418d6e01e616d8d95dec1253c7a909acf175d34e47cb5e100;

    /// @custom:storage-location erc7201:manager.vesting.plopmenz
    struct Storage {
        address manager;
    }

    function getStorage() internal pure returns (Storage storage $) {
        assembly {
            $.slot := 0x9bd030a8ec256b418d6e01e616d8d95dec1253c7a909acf175d34e47cb5e100
        }
    }
}
