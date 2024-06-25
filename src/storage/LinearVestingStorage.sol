// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LinearVestingStorage {
    // keccak256(abi.encode(uint256(keccak256("linear.vesting.plopmenz")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SLOT = 0x7424e9331a1a664cd2534451a453e8af8c82aa8e57e61f926d03aeb673afb400;

    /// @custom:storage-location erc7201:linear.vesting.plopmenz
    struct Storage {
        uint128 amount;
        uint64 start;
        uint64 duration;
    }

    function getStorage() internal pure returns (Storage storage $) {
        assembly {
            $.slot := SLOT
        }
    }
}
