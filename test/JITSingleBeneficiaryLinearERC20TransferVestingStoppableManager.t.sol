// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import {
    JITSingleBeneficiaryLinearERC20TransferVestingStoppableManager,
    SingleBeneficiaryLinearERC20TransferVestingStoppable
} from "../src/managed/JITSingleBeneficiaryLinearERC20TransferVestingStoppableManager.sol";
import {ERC20Mock, IERC20Mintable} from "./mocks/ERC20Mock.sol";

contract JITSingleBeneficiaryLinearERC20TransferVestingStoppableManagerTest is Test {
    ERC20Mock public erc20;
    JITSingleBeneficiaryLinearERC20TransferVestingStoppableManager public manager;

    function setUp() public {
        erc20 = new ERC20Mock();
        manager = new JITSingleBeneficiaryLinearERC20TransferVestingStoppableManager(erc20, address(this));
    }

    function getVesting(uint96 amount, uint16 duration, uint16 timePassed, uint16 timeAgoStarted, address beneficiary)
        internal
        returns (SingleBeneficiaryLinearERC20TransferVestingStoppable vesting, uint128 expected, uint64 start)
    {
        vm.assume(duration != 0 && block.timestamp > timeAgoStarted && beneficiary != address(0));
        start = uint64(block.timestamp - timeAgoStarted);
        vesting = SingleBeneficiaryLinearERC20TransferVestingStoppable(
            manager.createVesting(amount, start, duration, beneficiary)
        );
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
        SingleBeneficiaryLinearERC20TransferVestingStoppable vesting =
            SingleBeneficiaryLinearERC20TransferVestingStoppable(vestingAddress);
        vm.assertEq(address(vesting.token()), address(manager.token()));
        vm.assertEq(vesting.amount(), amount);
        vm.assertEq(vesting.start(), start);
        vm.assertEq(vesting.duration(), duration);
        //vm.assertEq(vesting.beneficiary(), beneficiary);
    }

    function test_release(uint96 amount, uint16 duration, uint16 timePassed, uint16 timeAgoStarted, address beneficiary)
        public
    {
        (SingleBeneficiaryLinearERC20TransferVestingStoppable vesting, uint128 expected, uint64 start) =
            getVesting(amount, duration, timePassed, timeAgoStarted, beneficiary);
        uint256 released = manager.release(amount, start, duration, beneficiary);
        console2.log(expected);
        vm.assertEq(erc20.balanceOf(beneficiary), expected);
        vm.assertEq(released, expected);
        vm.assertEq(vesting.released(), expected);
        vm.assertEq(vesting.releasable(), 0);
    }

    function test_stop(
        uint96 amount,
        uint16 duration,
        uint16 timePassed,
        uint16 timeAgoStarted,
        address beneficiary,
        uint16 newDuration
    ) public {
        vm.assume(newDuration < duration);
        (SingleBeneficiaryLinearERC20TransferVestingStoppable vesting,, uint64 start) =
            getVesting(amount, duration, timePassed, timeAgoStarted, beneficiary);
        bool invalid = timeAgoStarted + timePassed > newDuration;
        if (invalid) {
            vm.expectRevert();
        }
        manager.stop(amount, start, duration, beneficiary, newDuration);
        if (!invalid) {
            vm.assertEq(vesting.duration(), newDuration);
        }
    }

    function test_ownable(
        uint128 amount,
        uint64 start,
        uint64 duration,
        address beneficiary,
        address executor,
        uint64 newDuration
    ) public {
        vm.assume(newDuration < duration);

        vm.assume(executor != address(this));
        vm.prank(executor);
        vm.expectRevert();
        manager.createVesting(amount, start, duration, beneficiary);

        manager.createVesting(amount, start, duration, beneficiary);
        vm.prank(executor);
        vm.expectRevert();
        manager.stop(amount, start, duration, beneficiary, newDuration);
    }
}
