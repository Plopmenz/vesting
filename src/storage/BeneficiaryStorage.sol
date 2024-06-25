// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library BeneficiaryStorage {
    // keccak256(abi.encode(uint256(keccak256("beneficiary.vesting.plopmenz")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SLOT = 0xbb9095517aacf757092c3cba47e08bd12f912043ab684917bf8b786ef53a9400;

    /// @custom:storage-location erc7201:beneficiary.vesting.plopmenz
    struct Storage {
        address beneficiary;
    }

    function getStorage() internal pure returns (Storage storage $) {
        assembly {
            $.slot := SLOT
        }
    }
}
