// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "../lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import {SingleBeneficiaryLinearERC20TransferVesting, IERC20} from "./SingleBeneficiaryLinearERC20TransferVesting.sol";
import {Vesting} from "./vesting/Vesting.sol";
import {LinearVesting} from "./vesting/LinearVesting.sol";
import {Manager} from "./vesting/Manager.sol";
import {Stoppable} from "./vesting/Stoppable.sol";

contract SingleBeneficiaryLinearERC20TransferVestingStoppable is
    SingleBeneficiaryLinearERC20TransferVesting,
    Manager,
    Stoppable
{
    function __SingleBeneficiaryLinearERC20TransferVestingStoppable_init(
        IERC20 _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        address _beneficiary,
        address _manager
    ) internal {
        __SingleBeneficiaryLinearERC20TransferVesting_init(_token, _amount, _start, _duration, _beneficiary);
        __Manager_init(_manager);
        __Stoppable_init();
    }

    function _vestingUnlocked(uint256 _timestamp)
        internal
        view
        override(Stoppable, LinearVesting, Vesting)
        returns (uint256)
    {
        return super._vestingUnlocked(_timestamp);
    }
}

contract SingleBeneficiaryLinearERC20TransferVestingStoppableStandalone is
    SingleBeneficiaryLinearERC20TransferVestingStoppable
{
    constructor(
        IERC20 _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        address _beneficiary,
        address _manager
    ) {
        __SingleBeneficiaryLinearERC20TransferVestingStoppable_init(
            _token, _amount, _start, _duration, _beneficiary, _manager
        );
    }
}

contract SingleBeneficiaryLinearERC20TransferVestingStoppableProxy is
    Initializable,
    SingleBeneficiaryLinearERC20TransferVestingStoppable
{
    constructor() {
        _disableInitializers();
    }

    function initialize(
        IERC20 _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        address _beneficiary,
        address _manager
    ) external initializer {
        __SingleBeneficiaryLinearERC20TransferVestingStoppable_init(
            _token, _amount, _start, _duration, _beneficiary, _manager
        );
    }
}
