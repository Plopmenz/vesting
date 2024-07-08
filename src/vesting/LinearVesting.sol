// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VestingBase} from "./VestingBase.sol";

import {LinearVestingStorage} from "../storage/LinearVestingStorage.sol";

abstract contract LinearVesting is VestingBase {
    event LinearVestingCreated(uint128 amount, uint64 start, uint64 duration);

    function __LinearVesting_init(uint128 _amount, uint64 _start, uint64 _duration) internal {
        emit LinearVestingCreated(_amount, _start, _duration);
        LinearVestingStorage.Storage storage $ = LinearVestingStorage.getStorage();
        $.amount = _amount;
        $.start = _start;
        $.duration = _duration;
    }

    function amount() public view virtual returns (uint128) {
        LinearVestingStorage.Storage storage $ = LinearVestingStorage.getStorage();
        return $.amount;
    }

    function start() public view virtual returns (uint64) {
        LinearVestingStorage.Storage storage $ = LinearVestingStorage.getStorage();
        return $.start;
    }

    function duration() public view virtual returns (uint64) {
        LinearVestingStorage.Storage storage $ = LinearVestingStorage.getStorage();
        return $.duration;
    }

    // From Openzeppelin VestingWallet (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/contracts/finance/VestingWallet.sol)
    function _vestingUnlocked(uint256 _timestamp) internal view virtual override returns (uint256) {
        if (_timestamp < start()) {
            return 0;
        } else if (_timestamp >= (start() + duration())) {
            return amount();
        } else {
            return (amount() * (_timestamp - start())) / duration();
        }
    }
}
