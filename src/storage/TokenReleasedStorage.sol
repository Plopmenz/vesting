// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library TokenReleasedStorage {
    // keccak256(abi.encode(uint256(keccak256("token.released.vesting.plopmenz")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SLOT = 0x17484d0b5c499956860a319120c24df5e7d1b203d93fd8ed1a4435c8f68e3500;

    /// @custom:storage-location erc7201:token.released.vesting.plopmenz
    struct Storage {
        mapping(uint256 tokenId => uint256) released;
    }

    function getStorage() internal pure returns (Storage storage $) {
        assembly {
            $.slot := SLOT
        }
    }
}
