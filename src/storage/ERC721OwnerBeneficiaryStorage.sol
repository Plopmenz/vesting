// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC721} from "../../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

library ERC721OwnerBeneficiaryStorage {
    // keccak256(abi.encode(uint256(keccak256("erc721.owner.vesting.plopmenz")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SLOT = 0x7faec5a30f043be68474f3cdf79dfd1d5fbbd28ecafc50119b03842edcbabe00;

    /// @custom:storage-location erc7201:erc721.owner.vesting.plopmenz
    struct Storage {
        IERC721 ownerToken;
    }

    function getStorage() internal pure returns (Storage storage $) {
        assembly {
            $.slot := SLOT
        }
    }
}
