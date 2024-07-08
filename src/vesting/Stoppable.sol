// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VestingBase} from "./VestingBase.sol";
import {Managed} from "./Managed.sol";

import {StoppableStorage} from "../storage/StoppableStorage.sol";

/// @dev This does not burn or recover any tokens inside of the contract that might become unobtainable due to the earlier stop date!
abstract contract Stoppable is VestingBase, Managed {
    error StopMustBeInTheFuture(uint64 stop, uint64 currentTime);

    event StopAt(uint64 stop);

    function __Stoppable_init() internal {}

    function stop() public view virtual returns (uint64) {
        StoppableStorage.Storage storage $ = StoppableStorage.getStorage();
        return $.stop;
    }

    function stopAt(uint64 timestamp) public virtual onlyManager {
        StoppableStorage.Storage storage $ = StoppableStorage.getStorage();
        if (timestamp < block.timestamp) {
            revert StopMustBeInTheFuture(timestamp, uint64(block.timestamp));
        }

        emit StopAt(timestamp);
        $.stop = timestamp;
    }

    function _vestingUnlocked(uint256 _timestamp) internal view virtual override returns (uint256) {
        StoppableStorage.Storage storage $ = StoppableStorage.getStorage();
        if ($.stop != 0 && $.stop < _timestamp) {
            return super._vestingUnlocked($.stop);
        } else {
            return super._vestingUnlocked(_timestamp);
        }
    }
}
