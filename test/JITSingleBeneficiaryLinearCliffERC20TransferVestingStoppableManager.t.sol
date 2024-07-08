// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import {
    JITSingleBeneficiaryLinearCliffERC20TransferVestingStoppableManager,
    SingleBeneficiaryLinearCliffERC20TransferVestingStoppable
} from "../src/managed/JITSingleBeneficiaryLinearCliffERC20TransferVestingStoppableManager.sol";
import {ERC20Mock, IERC20Mintable} from "./mocks/ERC20Mock.sol";

contract JITSingleBeneficiaryLinearCliffERC20TransferVestingStoppableManagerTest is Test {
    ERC20Mock public erc20;
    JITSingleBeneficiaryLinearCliffERC20TransferVestingStoppableManager public manager;

    function setUp() public {
        erc20 = new ERC20Mock();
        manager = new JITSingleBeneficiaryLinearCliffERC20TransferVestingStoppableManager(erc20, address(this));
    }

    function getVesting(
        uint96 amount,
        uint16 duration,
        uint16 timePassed,
        uint16 timeAgoStarted,
        address beneficiary,
        uint64 cliff
    )
        internal
        returns (SingleBeneficiaryLinearCliffERC20TransferVestingStoppable vesting, uint128 expected, uint64 start)
    {
        vm.assume(duration != 0 && block.timestamp > timeAgoStarted && beneficiary != address(0));
        start = uint64(block.timestamp - timeAgoStarted);
        vesting = SingleBeneficiaryLinearCliffERC20TransferVestingStoppable(
            manager.createVesting(amount, start, duration, beneficiary, cliff)
        );
        if (block.timestamp + timePassed < cliff) {
            expected = 0;
        } else if (timePassed > duration) {
            expected = amount;
        } else {
            expected = ((timePassed + timeAgoStarted) * uint128(amount)) / duration;
        }
        vm.warp(block.timestamp + timePassed);
    }

    function test_init(uint128 amount, uint64 start, uint64 duration, address beneficiary, uint64 cliff) public {
        address vestingAddress = manager.createVesting(amount, start, duration, beneficiary, cliff);
        vm.assertEq(manager.getAddress(amount, start, duration, beneficiary, cliff), vestingAddress);
        SingleBeneficiaryLinearCliffERC20TransferVestingStoppable vesting =
            SingleBeneficiaryLinearCliffERC20TransferVestingStoppable(vestingAddress);
        vm.assertEq(address(vesting.token()), address(manager.token()));
        vm.assertEq(vesting.amount(), amount);
        vm.assertEq(vesting.start(), start);
        vm.assertEq(vesting.duration(), duration);
        vm.assertEq(vesting.beneficiary(), beneficiary);
        vm.assertEq(vesting.cliff(), cliff);
    }

    function test_release(
        uint96 amount,
        uint16 duration,
        uint16 timePassed,
        uint16 timeAgoStarted,
        address beneficiary,
        uint64 cliff
    ) public {
        (SingleBeneficiaryLinearCliffERC20TransferVestingStoppable vesting, uint128 expected, uint64 start) =
            getVesting(amount, duration, timePassed, timeAgoStarted, beneficiary, cliff);
        uint256 released = manager.release(amount, start, duration, beneficiary, cliff);
        console2.log(expected);
        vm.assertEq(erc20.balanceOf(beneficiary), expected);
        vm.assertEq(released, expected);
        vm.assertEq(vesting.released(), expected);
        vm.assertEq(vesting.releasable(), 0);
    }

    function test_stopAt(
        uint96 amount,
        uint16 duration,
        uint16 timePassed,
        uint16 timeAgoStarted,
        address beneficiary,
        uint64 cliff,
        uint16 stopAt,
        uint16 afterStop
    ) public {
        (SingleBeneficiaryLinearCliffERC20TransferVestingStoppable vesting,, uint64 start) =
            getVesting(amount, duration, timePassed, timeAgoStarted, beneficiary, cliff);
        bool invalid = block.timestamp > stopAt;
        if (invalid) {
            vm.expectRevert();
        }
        manager.stopAt(amount, start, duration, beneficiary, cliff, stopAt);
        if (!invalid) {
            vm.assertEq(vesting.stop(), stopAt);
            vm.warp(stopAt);
            uint256 releasable = vesting.releasable();
            vm.warp(block.timestamp + afterStop);
            vm.assertEq(vesting.releasable(), releasable);
        }
    }

    function test_ownable(
        uint128 amount,
        uint64 start,
        uint64 duration,
        address beneficiary,
        uint64 cliff,
        address executor,
        uint64 stopAt
    ) public {
        vm.assume(stopAt >= block.timestamp);

        vm.assume(executor != address(this));
        vm.prank(executor);
        vm.expectRevert();
        manager.createVesting(amount, start, duration, beneficiary, cliff);

        manager.createVesting(amount, start, duration, beneficiary, cliff);
        vm.prank(executor);
        vm.expectRevert();
        manager.stopAt(amount, start, duration, beneficiary, cliff, stopAt);
    }
}
