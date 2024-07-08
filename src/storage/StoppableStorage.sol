// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library StoppableStorage {
    // keccak256(abi.encode(uint256(keccak256("stop.vesting.plopmenz")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SLOT = 0x7aa8836cb72a61dd01316d20aba571501a9d434d037b3add1c8ecb2960effd00;

    /// @custom:storage-location erc7201:stop.vesting.plopmenz
    struct Storage {
        uint64 stop;
    }

    function getStorage() internal pure returns (Storage storage $) {
        assembly {
            $.slot := SLOT
        }
    }
}
