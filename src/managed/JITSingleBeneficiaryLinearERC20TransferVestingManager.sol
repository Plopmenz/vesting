// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Clones} from "../../lib/openzeppelin-contracts/contracts/proxy/Clones.sol";

import {
    SingleBeneficiaryLinearERC20TransferVesting,
    SingleBeneficiaryLinearERC20TransferVestingProxy
} from "../SingleBeneficiaryLinearERC20TransferVesting.sol";
import {IERC20Mintable} from "../rewards/IERC20Mintable.sol";

contract JITSingleBeneficiaryLinearERC20TransferVestingManager is Ownable {
    event VestingCreated(address vesting, uint128 amount, uint64 start, uint64 duration, address indexed beneficiary);

    IERC20Mintable public immutable token;
    SingleBeneficiaryLinearERC20TransferVestingProxy public immutable implementation;

    constructor(IERC20Mintable _token, address _admin) Ownable(_admin) {
        token = _token;
        implementation = new SingleBeneficiaryLinearERC20TransferVestingProxy();
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
        SingleBeneficiaryLinearERC20TransferVestingProxy(vesting).initialize(
            token, _amount, _start, _duration, _beneficiary
        );
        emit VestingCreated(vesting, _amount, _start, _duration, _beneficiary);
    }

    function release(uint128 _amount, uint64 _start, uint64 _duration, address _beneficiary)
        external
        returns (uint256 released)
    {
        SingleBeneficiaryLinearERC20TransferVesting vesting =
            SingleBeneficiaryLinearERC20TransferVesting(getAddress(_amount, _start, _duration, _beneficiary));
        released = vesting.releasable();
        token.mint(address(vesting), released);
        vesting.release();
    }
}
