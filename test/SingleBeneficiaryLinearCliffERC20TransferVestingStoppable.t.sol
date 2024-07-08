// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import {
    SingleBeneficiaryLinearCliffERC20TransferVestingStoppable,
    SingleBeneficiaryLinearCliffERC20TransferVestingStoppableStandalone
} from "../src/SingleBeneficiaryLinearCliffERC20TransferVestingStoppable.sol";
import {ERC20Mock, IERC20} from "./mocks/ERC20Mock.sol";

contract SingleBeneficiaryLinearCliffERC20TransferVestingStoppableTest is Test {
    ERC20Mock public erc20;

    function setUp() public {
        erc20 = new ERC20Mock();
    }

    function getVesting(
        uint96 amount,
        uint16 duration,
        uint16 timePassed,
        uint16 timeAgoStarted,
        address beneficiary,
        uint64 cliff,
        address manager
    ) internal returns (SingleBeneficiaryLinearCliffERC20TransferVestingStoppable vesting, uint128 expected) {
        vm.assume(duration != 0 && block.timestamp > timeAgoStarted && beneficiary != address(0));
        vesting = new SingleBeneficiaryLinearCliffERC20TransferVestingStoppableStandalone(
            erc20, amount, uint64(block.timestamp - timeAgoStarted), duration, beneficiary, cliff, manager
        );
        if (block.timestamp + timePassed < cliff) {
            expected = 0;
        } else if (timePassed > duration) {
            expected = amount;
        } else {
            expected = ((timePassed + timeAgoStarted) * uint128(amount)) / duration;
        }
        vm.warp(block.timestamp + timePassed);
        erc20.mint(address(vesting), type(uint256).max);
    }

    function test_release(
        uint96 amount,
        uint16 duration,
        uint16 timePassed,
        uint16 timeAgoStarted,
        address beneficiary,
        uint64 cliff,
        address manager
    ) public {
        (SingleBeneficiaryLinearCliffERC20TransferVestingStoppable vesting, uint128 expected) =
            getVesting(amount, duration, timePassed, timeAgoStarted, beneficiary, cliff, manager);
        vm.assertEq(vesting.releasable(), expected);
        vesting.release();
        vm.assertEq(erc20.balanceOf(beneficiary), expected);
        vm.assertEq(vesting.released(), expected);
        vm.assertEq(vesting.releasable(), 0);
    }

    function test_beforeStart(
        uint96 amount,
        uint16 duration,
        uint16 startsIn,
        address beneficiary,
        uint64 cliff,
        address manager
    ) public {
        vm.assume(duration != 0);
        SingleBeneficiaryLinearCliffERC20TransferVestingStoppable vesting = new SingleBeneficiaryLinearCliffERC20TransferVestingStoppableStandalone(
            erc20, amount, uint64(block.timestamp + startsIn), duration, beneficiary, cliff, manager
        );
        erc20.mint(address(vesting), type(uint256).max);
        vm.assertEq(vesting.releasable(), 0);
    }

    function test_init(
        IERC20 token,
        uint128 amount,
        uint64 start,
        uint64 duration,
        address beneficiary,
        uint64 cliff,
        address manager
    ) public {
        SingleBeneficiaryLinearCliffERC20TransferVestingStoppable vesting = new SingleBeneficiaryLinearCliffERC20TransferVestingStoppableStandalone(
            token, amount, start, duration, beneficiary, cliff, manager
        );
        vm.assertEq(address(vesting.token()), address(token));
        vm.assertEq(vesting.amount(), amount);
        vm.assertEq(vesting.start(), start);
        vm.assertEq(vesting.duration(), duration);
        vm.assertEq(vesting.cliff(), cliff);
        vm.assertEq(vesting.beneficiary(), beneficiary);
        vm.assertEq(vesting.manager(), manager);
    }

    function test_stop(
        uint96 amount,
        uint16 duration,
        uint16 timePassed,
        uint16 timeAgoStarted,
        address beneficiary,
        uint64 cliff,
        address manager,
        uint16 stopAt,
        uint16 afterStop
    ) public {
        (SingleBeneficiaryLinearCliffERC20TransferVestingStoppable vesting,) =
            getVesting(amount, duration, timePassed, timeAgoStarted, beneficiary, cliff, manager);
        bool invalid = block.timestamp > stopAt;
        if (invalid) {
            vm.expectRevert();
        }
        vm.prank(manager);
        vesting.stopAt(stopAt);
        if (!invalid) {
            vm.assertEq(vesting.stop(), stopAt);
            vm.warp(stopAt);
            uint256 releasable = vesting.releasable();
            vm.warp(block.timestamp + afterStop);
            vm.assertEq(vesting.releasable(), releasable);
        }
    }

    function test_stopNotManager(
        uint96 amount,
        uint16 duration,
        uint16 timePassed,
        uint16 timeAgoStarted,
        address beneficiary,
        uint64 cliff,
        address manager,
        uint16 stopAt
    ) public {
        vm.assume(stopAt >= block.timestamp);
        vm.assume(address(this) != manager);

        (SingleBeneficiaryLinearCliffERC20TransferVestingStoppable vesting,) =
            getVesting(amount, duration, timePassed, timeAgoStarted, beneficiary, cliff, manager);
        vm.expectRevert();
        vesting.stopAt(stopAt);
    }
}
