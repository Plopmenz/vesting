// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ReleasedStorage {
    // keccak256(abi.encode(uint256(keccak256("released.vesting.plopmenz")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SLOT = 0x8df55bf63e7e5c2484a7ac576946139c1fe207dc43b74382c8f112dfb519ec00;

    /// @custom:storage-location erc7201:released.vesting.plopmenz
    struct Storage {
        uint256 released;
    }

    function getStorage() internal pure returns (Storage storage $) {
        assembly {
            $.slot := SLOT
        }
    }
}
