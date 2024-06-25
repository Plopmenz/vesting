// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library AddressReleasedStorage {
    // keccak256(abi.encode(uint256(keccak256("address.released.vesting.plopmenz")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SLOT = 0xc4e75214b880e2f02c9ba9e7142b1d7fa46440b56be3e6738544df668bb14100;

    /// @custom:storage-location erc7201:address.released.vesting.plopmenz
    struct Storage {
        mapping(address account => uint256) released;
    }

    function getStorage() internal pure returns (Storage storage $) {
        assembly {
            $.slot := SLOT
        }
    }
}
