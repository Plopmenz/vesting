// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BeneficiaryStorage} from "../storage/BeneficiaryStorage.sol";

abstract contract Beneficiary {
    event BeneficiaryCreated(address indexed beneficiary);

    function __Beneficiary_init(address _beneficiary) internal {
        emit BeneficiaryCreated(_beneficiary);
        BeneficiaryStorage.Storage storage $ = BeneficiaryStorage.getStorage();
        $.beneficiary = _beneficiary;
    }

    function beneficiary() public view virtual returns (address) {
        BeneficiaryStorage.Storage storage $ = BeneficiaryStorage.getStorage();
        return $.beneficiary;
    }
}
