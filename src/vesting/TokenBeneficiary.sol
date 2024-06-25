// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract TokenBeneficiary {
    function beneficiary(uint256 _tokenId) public view virtual returns (address);
}
