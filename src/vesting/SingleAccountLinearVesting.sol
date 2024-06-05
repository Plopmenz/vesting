// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VestingUtils} from "./VestingUtils.sol";

abstract contract SingleAccountLinearVesting {
    uint96 public immutable amount;
    uint64 public immutable start;
    uint64 public immutable duration;

    uint96 public released;

    constructor(uint96 _amount, uint64 _start, uint64 _duration) {
        amount = _amount;
        start = _start;
        duration = _duration;
    }

    function reward(address _beneficiary, uint96 _amount) internal virtual;

    /// @notice Getter for the address that will receive the tokens.
    function beneficiary() public view virtual returns (address);

    /// @notice Getter for the amount of releasable tokens.
    function releasable() public view virtual returns (uint96) {
        return VestingUtils.linearVesting(start, duration, amount, uint64(block.timestamp)) - released;
    }

    /// @notice Release the tokens that have already vested.
    function release() public virtual {
        address releaseBeneficiary = beneficiary();
        uint96 releaseAmount = releasable();
        released += releaseAmount;
        reward(releaseBeneficiary, releaseAmount);
    }
}
