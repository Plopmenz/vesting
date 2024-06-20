// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VestingUtils} from "./VestingUtils.sol";

library SingleAccountLinearVestingStorage {
    bytes32 private constant SLOT = keccak256("single.address.linear.vesting.plopmenz");

    struct Storage {
        uint128 amount;
        uint64 start;
        uint64 duration;
        uint128 released;
    }

    function getStorage() internal pure returns (Storage storage $) {
        bytes32 slot = SLOT;
        assembly {
            $.slot := slot
        }
    }
}

abstract contract SingleAccountLinearVesting {
    function __SingleAccountLinearVesting_init(uint128 _amount, uint64 _start, uint64 _duration) internal {
        SingleAccountLinearVestingStorage.Storage storage $ = SingleAccountLinearVestingStorage.getStorage();
        $.amount = _amount;
        $.start = _start;
        $.duration = _duration;
    }

    function amount() external view returns (uint128) {
        SingleAccountLinearVestingStorage.Storage storage $ = SingleAccountLinearVestingStorage.getStorage();
        return $.amount;
    }

    function start() external view returns (uint64) {
        SingleAccountLinearVestingStorage.Storage storage $ = SingleAccountLinearVestingStorage.getStorage();
        return $.start;
    }

    function duration() external view returns (uint64) {
        SingleAccountLinearVestingStorage.Storage storage $ = SingleAccountLinearVestingStorage.getStorage();
        return $.duration;
    }

    function released() external view returns (uint128) {
        SingleAccountLinearVestingStorage.Storage storage $ = SingleAccountLinearVestingStorage.getStorage();
        return $.released;
    }

    function reward(address _beneficiary, uint128 _amount) internal virtual;

    /// @notice Getter for the address that will receive the tokens.
    function beneficiary() public view virtual returns (address);

    /// @notice Getter for the amount of releasable tokens.
    function releasable() public view virtual returns (uint128) {
        SingleAccountLinearVestingStorage.Storage storage $ = SingleAccountLinearVestingStorage.getStorage();
        return uint128(VestingUtils.linearVesting($.start, $.duration, $.amount, uint64(block.timestamp))) - $.released;
    }

    /// @notice Release the tokens that have already vested.
    function release() public virtual {
        SingleAccountLinearVestingStorage.Storage storage $ = SingleAccountLinearVestingStorage.getStorage();
        address releaseBeneficiary = beneficiary();
        uint128 releaseAmount = releasable();
        $.released += releaseAmount;
        reward(releaseBeneficiary, releaseAmount);
    }
}
