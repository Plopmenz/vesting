// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vesting} from "./Vesting.sol";

import {AddressReleasedStorage} from "../storage/AddressReleasedStorage.sol";

abstract contract AddressReleased is Vesting {
    function __AddressReleased_init() internal {}

    function released(address _account) public view virtual returns (uint256) {
        AddressReleasedStorage.Storage storage $ = AddressReleasedStorage.getStorage();
        return $.released[_account];
    }

    function releasable(address _account) public view virtual returns (uint256) {
        return _vestingUnlocked(block.timestamp) - released(_account);
    }

    function _release(address _account) internal virtual {
        uint256 releaseAmount = releasable(_account);
        AddressReleasedStorage.Storage storage $ = AddressReleasedStorage.getStorage();
        $.released[_account] += releaseAmount;
        _reward(_account, releaseAmount);
    }
}
