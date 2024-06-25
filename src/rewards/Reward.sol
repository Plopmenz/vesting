// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Reward {
    function _reward(address _beneficiary, uint256 _amount) internal virtual;
}
