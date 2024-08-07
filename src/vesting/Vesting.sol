// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Reward} from "../rewards/Reward.sol";

abstract contract Vesting is Reward {
    function _vestingUnlocked(uint256 _timestamp) internal view virtual returns (uint256);
}
