// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

library ERC20RewardStorage {
    // keccak256(abi.encode(uint256(keccak256("erc20.reward.vesting.plopmenz")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SLOT = 0xa25687f8fc2dc2a054247bc2f1b14dead2930a16ee048f0e45ca4763720c7900;

    /// @custom:storage-location erc7201:erc20.reward.vesting.plopmenz
    struct Storage {
        IERC20 token;
    }

    function getStorage() internal pure returns (Storage storage $) {
        assembly {
            $.slot := SLOT
        }
    }
}
