// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "../lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import {SingleBeneficiaryLinearVesting} from "./vesting/extensions/SingleBeneficiaryLinearVesting.sol";
import {ERC20MintReward, IERC20Mintable} from "./rewards/ERC20MintReward.sol";

contract SingleBeneficiaryLinearERC20MintVesting is SingleBeneficiaryLinearVesting, ERC20MintReward {
    function __SingleBeneficiaryLinearERC20MintVesting_init(
        IERC20Mintable _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        address _beneficiary
    ) internal {
        __SingleBeneficiaryLinearVesting_init(_amount, _start, _duration, _beneficiary);
        __ERC20MintReward_init(_token);
    }
}

contract SingleBeneficiaryLinearERC20MintVestingStandalone is SingleBeneficiaryLinearERC20MintVesting {
    constructor(IERC20Mintable _token, uint128 _amount, uint64 _start, uint64 _duration, address _beneficiary) {
        __SingleBeneficiaryLinearERC20MintVesting_init(_token, _amount, _start, _duration, _beneficiary);
    }
}

contract SingleBeneficiaryLinearERC20MintVestingProxy is Initializable, SingleBeneficiaryLinearERC20MintVesting {
    constructor() {
        _disableInitializers();
    }

    function initialize(IERC20Mintable _token, uint128 _amount, uint64 _start, uint64 _duration, address _beneficiary)
        external
        initializer
    {
        __SingleBeneficiaryLinearERC20MintVesting_init(_token, _amount, _start, _duration, _beneficiary);
    }
}
