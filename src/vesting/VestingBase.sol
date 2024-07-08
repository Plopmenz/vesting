// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vesting} from "./Vesting.sol";

abstract contract VestingBase is Vesting {
    error Unimplemented();

    function _vestingUnlocked(uint256 _timestamp) internal view virtual override returns (uint256) {
        (_timestamp);
        revert Unimplemented();
    }
}
