// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VestingBase} from "./VestingBase.sol";

import {CliffStorage} from "../storage/CliffStorage.sol";

abstract contract Cliff is VestingBase {
    event CliffCreated(uint64 cliff);

    function __Cliff_init(uint64 _cliff) internal {
        emit CliffCreated(_cliff);
        CliffStorage.Storage storage $ = CliffStorage.getStorage();
        $.cliff = _cliff;
    }

    function cliff() public view virtual returns (uint128) {
        CliffStorage.Storage storage $ = CliffStorage.getStorage();
        return $.cliff;
    }

    function _vestingUnlocked(uint256 _timestamp) internal view virtual override returns (uint256) {
        if (_timestamp < cliff()) {
            return 0;
        } else {
            return super._vestingUnlocked(_timestamp);
        }
    }
}
