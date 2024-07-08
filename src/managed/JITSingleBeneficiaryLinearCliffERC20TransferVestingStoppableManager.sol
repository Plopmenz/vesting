// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Clones} from "../../lib/openzeppelin-contracts/contracts/proxy/Clones.sol";

import {
    SingleBeneficiaryLinearCliffERC20TransferVestingStoppable,
    SingleBeneficiaryLinearCliffERC20TransferVestingStoppableProxy
} from "../SingleBeneficiaryLinearCliffERC20TransferVestingStoppable.sol";
import {IERC20Mintable} from "../rewards/IERC20Mintable.sol";

contract JITSingleBeneficiaryLinearCliffERC20TransferVestingStoppableManager is Ownable {
    IERC20Mintable public immutable token;
    SingleBeneficiaryLinearCliffERC20TransferVestingStoppableProxy public immutable implementation;

    constructor(IERC20Mintable _token, address _admin) Ownable(_admin) {
        token = _token;
        implementation = new SingleBeneficiaryLinearCliffERC20TransferVestingStoppableProxy();
    }

    function getAddress(uint128 _amount, uint64 _start, uint64 _duration, address _beneficiary, uint64 _cliff)
        public
        view
        returns (address)
    {
        return Clones.predictDeterministicAddress(
            address(implementation), keccak256(abi.encodePacked(_amount, _start, _duration, _beneficiary, _cliff))
        );
    }

    function createVesting(uint128 _amount, uint64 _start, uint64 _duration, address _beneficiary, uint64 _cliff)
        external
        onlyOwner
        returns (address vesting)
    {
        vesting = Clones.cloneDeterministic(
            address(implementation), keccak256(abi.encodePacked(_amount, _start, _duration, _beneficiary, _cliff))
        );
        SingleBeneficiaryLinearCliffERC20TransferVestingStoppableProxy(vesting).initialize(
            token, _amount, _start, _duration, _beneficiary, _cliff, address(this)
        );
    }

    function release(uint128 _amount, uint64 _start, uint64 _duration, address _beneficiary, uint64 _cliff)
        external
        returns (uint256 released)
    {
        SingleBeneficiaryLinearCliffERC20TransferVestingStoppable vesting =
        SingleBeneficiaryLinearCliffERC20TransferVestingStoppable(
            getAddress(_amount, _start, _duration, _beneficiary, _cliff)
        );
        released = vesting.releasable();
        token.mint(address(vesting), released);
        vesting.release();
    }

    function stopAt(
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        address _beneficiary,
        uint64 _cliff,
        uint64 _stopAt
    ) external onlyOwner {
        SingleBeneficiaryLinearCliffERC20TransferVestingStoppable vesting =
        SingleBeneficiaryLinearCliffERC20TransferVestingStoppable(
            getAddress(_amount, _start, _duration, _beneficiary, _cliff)
        );
        vesting.stopAt(_stopAt);
    }
}
