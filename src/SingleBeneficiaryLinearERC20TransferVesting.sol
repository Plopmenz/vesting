// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "../lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import {SingleBeneficiaryLinearVesting} from "./vesting/extensions/SingleBeneficiaryLinearVesting.sol";
import {ERC20TransferReward, IERC20} from "./rewards/ERC20TransferReward.sol";

contract SingleBeneficiaryLinearERC20TransferVesting is SingleBeneficiaryLinearVesting, ERC20TransferReward {
    function __SingleBeneficiaryLinearERC20TransferVesting_init(
        IERC20 _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        address _beneficiary
    ) internal {
        __SingleBeneficiaryLinearVesting_init(_amount, _start, _duration, _beneficiary);
        __ERC20TransferReward_init(_token);
    }
}

contract SingleBeneficiaryLinearERC20TransferVestingStandalone is SingleBeneficiaryLinearERC20TransferVesting {
    constructor(IERC20 _token, uint128 _amount, uint64 _start, uint64 _duration, address _beneficiary) {
        __SingleBeneficiaryLinearERC20TransferVesting_init(_token, _amount, _start, _duration, _beneficiary);
    }
}

contract SingleBeneficiaryLinearERC20TransferVestingProxy is
    Initializable,
    SingleBeneficiaryLinearERC20TransferVesting
{
    constructor() {
        _disableInitializers();
    }

    function initialize(IERC20 _token, uint128 _amount, uint64 _start, uint64 _duration, address _beneficiary)
        external
        initializer
    {
        __SingleBeneficiaryLinearERC20TransferVesting_init(_token, _amount, _start, _duration, _beneficiary);
    }
}
