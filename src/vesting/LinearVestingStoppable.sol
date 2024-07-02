// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Managed} from "./Managed.sol";

import {LinearVestingStorage} from "../storage/LinearVestingStorage.sol";

/// @dev This does not burn or recover any tokens inside of the contract that might become unobtainable due to the earlier stop date!
abstract contract LinearVestingStoppable is Managed {
    error StopMustBeInTheFuture(uint64 stop, uint64 currentTime);
    error StopMustDecreaseDuration(uint64 newDuration, uint64 oldDuration);

    event Stop(uint64 newDuration);

    function __LinearVestingStoppable_init() internal {}

    function stop(uint64 newDuration) public virtual onlyManager {
        LinearVestingStorage.Storage storage $ = LinearVestingStorage.getStorage();
        if ($.start + newDuration < block.timestamp) {
            revert StopMustBeInTheFuture($.start + newDuration, uint64(block.timestamp));
        }
        if (newDuration > $.duration) {
            revert StopMustDecreaseDuration(newDuration, $.duration);
        }

        emit Stop(newDuration);
        $.duration = newDuration;
    }
}
