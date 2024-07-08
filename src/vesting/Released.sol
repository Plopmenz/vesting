// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vesting} from "./Vesting.sol";

import {ReleasedStorage} from "../storage/ReleasedStorage.sol";

abstract contract Released is Vesting {
    function __Released_init() internal {}

    function released() public view virtual returns (uint256) {
        ReleasedStorage.Storage storage $ = ReleasedStorage.getStorage();
        return $.released;
    }

    function releasable() public view virtual returns (uint256) {
        return _vestingUnlocked(block.timestamp) - released();
    }

    function _release(address _account) internal virtual {
        uint256 releaseAmount = releasable();
        ReleasedStorage.Storage storage $ = ReleasedStorage.getStorage();
        $.released += releaseAmount;
        _reward(_account, releaseAmount);
    }
}
