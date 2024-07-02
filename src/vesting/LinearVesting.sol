// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vesting} from "./Vesting.sol";

import {LinearVestingStorage} from "../storage/LinearVestingStorage.sol";

abstract contract LinearVesting is Vesting {
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
    function _vestingUnlocked() internal view override returns (uint256) {
        if (block.timestamp < start()) {
            return 0;
        } else if (block.timestamp >= (start() + duration())) {
            return amount();
        } else {
            return (amount() * (block.timestamp - start())) / duration();
        }
    }
}
