// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "../lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import {SingleBeneficiaryLinearERC20TransferVesting, IERC20} from "./SingleBeneficiaryLinearERC20TransferVesting.sol";
import {Vesting} from "./vesting/Vesting.sol";
import {LinearVesting} from "./vesting/LinearVesting.sol";
import {Cliff} from "./vesting/Cliff.sol";
import {Manager} from "./vesting/Manager.sol";
import {Stoppable} from "./vesting/Stoppable.sol";

contract SingleBeneficiaryLinearCliffERC20TransferVestingStoppable is
    SingleBeneficiaryLinearERC20TransferVesting,
    Cliff,
    Manager,
    Stoppable
{
    function __SingleBeneficiaryLinearCliffERC20TransferVestingStoppable_init(
        IERC20 _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        address _beneficiary,
        uint64 _cliff,
        address _manager
    ) internal {
        __SingleBeneficiaryLinearERC20TransferVesting_init(_token, _amount, _start, _duration, _beneficiary);
        __Cliff_init(_cliff);
        __Manager_init(_manager);
        __Stoppable_init();
    }

    function _vestingUnlocked(uint256 _timestamp)
        internal
        view
        override(Stoppable, Cliff, LinearVesting, Vesting)
        returns (uint256)
    {
        return super._vestingUnlocked(_timestamp);
    }
}

contract SingleBeneficiaryLinearCliffERC20TransferVestingStoppableStandalone is
    SingleBeneficiaryLinearCliffERC20TransferVestingStoppable
{
    constructor(
        IERC20 _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        address _beneficiary,
        uint64 _cliff,
        address _manager
    ) {
        __SingleBeneficiaryLinearCliffERC20TransferVestingStoppable_init(
            _token, _amount, _start, _duration, _beneficiary, _cliff, _manager
        );
    }
}

contract SingleBeneficiaryLinearCliffERC20TransferVestingStoppableProxy is
    Initializable,
    SingleBeneficiaryLinearCliffERC20TransferVestingStoppable
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
        uint64 _cliff,
        address _manager
    ) external initializer {
        __SingleBeneficiaryLinearCliffERC20TransferVestingStoppable_init(
            _token, _amount, _start, _duration, _beneficiary, _cliff, _manager
        );
    }
}
