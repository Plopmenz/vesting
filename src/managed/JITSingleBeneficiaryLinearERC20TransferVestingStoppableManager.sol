// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Clones} from "../../lib/openzeppelin-contracts/contracts/proxy/Clones.sol";

import {
    SingleBeneficiaryLinearERC20TransferVestingStoppable,
    SingleBeneficiaryLinearERC20TransferVestingStoppableProxy
} from "../SingleBeneficiaryLinearERC20TransferVestingStoppable.sol";
import {IERC20Mintable} from "../rewards/IERC20Mintable.sol";

contract JITSingleBeneficiaryLinearERC20TransferVestingStoppableManager is Ownable {
    IERC20Mintable public immutable token;
    SingleBeneficiaryLinearERC20TransferVestingStoppableProxy public immutable implementation;

    constructor(IERC20Mintable _token, address _admin) Ownable(_admin) {
        token = _token;
        implementation = new SingleBeneficiaryLinearERC20TransferVestingStoppableProxy();
    }

    function getAddress(uint128 _amount, uint64 _start, uint64 _duration, address _beneficiary)
        public
        view
        returns (address)
    {
        return Clones.predictDeterministicAddress(
            address(implementation), keccak256(abi.encodePacked(_amount, _start, _duration, _beneficiary))
        );
    }

    function createVesting(uint128 _amount, uint64 _start, uint64 _duration, address _beneficiary)
        external
        onlyOwner
        returns (address vesting)
    {
        vesting = Clones.cloneDeterministic(
            address(implementation), keccak256(abi.encodePacked(_amount, _start, _duration, _beneficiary))
        );
        SingleBeneficiaryLinearERC20TransferVestingStoppableProxy(vesting).initialize(
            token, _amount, _start, _duration, _beneficiary, address(this)
        );
    }

    function release(uint128 _amount, uint64 _start, uint64 _duration, address _beneficiary)
        external
        returns (uint256 released)
    {
        SingleBeneficiaryLinearERC20TransferVestingStoppable vesting =
            SingleBeneficiaryLinearERC20TransferVestingStoppable(getAddress(_amount, _start, _duration, _beneficiary));
        released = vesting.releasable();
        token.mint(address(vesting), released);
        vesting.release();
    }

    function stopAt(uint128 _amount, uint64 _start, uint64 _duration, address _beneficiary, uint64 _stopAt)
        external
        onlyOwner
    {
        SingleBeneficiaryLinearERC20TransferVestingStoppable vesting =
            SingleBeneficiaryLinearERC20TransferVestingStoppable(getAddress(_amount, _start, _duration, _beneficiary));
        vesting.stopAt(_stopAt);
    }
}
