// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TokenReleased} from "../TokenReleased.sol";
import {LinearVesting} from "../LinearVesting.sol";

abstract contract MultiTokenLinearVesting is TokenReleased, LinearVesting {
    function __MultiTokenLinearVesting_init(uint128 _amount, uint64 _start, uint64 _duration) internal {
        __TokenReleased_init();
        __LinearVesting_init(_amount, _start, _duration);
    }

    function release(uint256 _tokenId) public virtual {
        _release(_tokenId);
    }
}
