// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import {
    JITSingleBeneficiaryLinearERC20TransferVestingManager,
    SingleBeneficiaryLinearERC20TransferVesting
} from "../src/managed/JITSingleBeneficiaryLinearERC20TransferVestingManager.sol";
import {ERC20Mock, IERC20Mintable} from "./mocks/ERC20Mock.sol";

contract JITSingleBeneficiaryLinearERC20TransferVestingManagerTest is Test {
    ERC20Mock public erc20;
    JITSingleBeneficiaryLinearERC20TransferVestingManager public manager;

    function setUp() public {
        erc20 = new ERC20Mock();
        manager = new JITSingleBeneficiaryLinearERC20TransferVestingManager(erc20, address(this));
    }

    function getVesting(uint96 amount, uint16 duration, uint16 timePassed, uint16 timeAgoStarted, address beneficiary)
        internal
        returns (SingleBeneficiaryLinearERC20TransferVesting vesting, uint128 expected, uint64 start)
    {
        vm.assume(duration != 0 && block.timestamp > timeAgoStarted && beneficiary != address(0));
        start = uint64(block.timestamp - timeAgoStarted);
        vesting =
            SingleBeneficiaryLinearERC20TransferVesting(manager.createVesting(amount, start, duration, beneficiary));
        if (timePassed > duration) {
            expected = amount;
        } else {
            expected = ((timePassed + timeAgoStarted) * uint128(amount)) / duration;
        }
        vm.warp(block.timestamp + timePassed);
    }

    function test_init(uint128 amount, uint64 start, uint64 duration, address beneficiary) public {
        address vestingAddress = manager.createVesting(amount, start, duration, beneficiary);
        vm.assertEq(manager.getAddress(amount, start, duration, beneficiary), vestingAddress);
        SingleBeneficiaryLinearERC20TransferVesting vesting =
            SingleBeneficiaryLinearERC20TransferVesting(vestingAddress);
        vm.assertEq(address(vesting.token()), address(manager.token()));
        vm.assertEq(vesting.amount(), amount);
        vm.assertEq(vesting.start(), start);
        vm.assertEq(vesting.duration(), duration);
        //vm.assertEq(vesting.beneficiary(), beneficiary);
    }

    function test_release(uint96 amount, uint16 duration, uint16 timePassed, uint16 timeAgoStarted, address beneficiary)
        public
    {
        (SingleBeneficiaryLinearERC20TransferVesting vesting, uint128 expected, uint64 start) =
            getVesting(amount, duration, timePassed, timeAgoStarted, beneficiary);
        uint256 released = manager.release(amount, start, duration, beneficiary);
        console2.log(expected);
        vm.assertEq(erc20.balanceOf(beneficiary), expected);
        vm.assertEq(released, expected);
        vm.assertEq(vesting.released(), expected);
        vm.assertEq(vesting.releasable(), 0);
    }

    function test_ownable(uint128 amount, uint64 start, uint64 duration, address beneficiary, address executor)
        public
    {
        vm.assume(executor != address(this));
        vm.prank(executor);
        vm.expectRevert();
        manager.createVesting(amount, start, duration, beneficiary);
    }
}
