// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Released} from "../Released.sol";
import {Beneficiary} from "../Beneficiary.sol";
import {LinearVesting} from "../LinearVesting.sol";

abstract contract SingleBeneficiaryLinearVesting is Released, Beneficiary, LinearVesting {
    function __SingleBeneficiaryLinearVesting_init(
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        address _beneficiary
    ) internal {
        __Released_init();
        __Beneficiary_init(_beneficiary);
        __LinearVesting_init(_amount, _start, _duration);
    }

    function release() public virtual {
        _release(beneficiary());
    }
}
