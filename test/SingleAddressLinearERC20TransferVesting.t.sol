// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import {SingleAddressLinearERC20TransferVesting} from "../src/SingleAddressLinearERC20TransferVesting.sol";
import {ERC20Mock, IERC20Mintable} from "./mocks/ERC20Mock.sol";

contract SingleAddressLinearERC20TransferVestingTest is Test {
    ERC20Mock public erc20;

    function setUp() public {
        erc20 = new ERC20Mock();
    }

    function getVesting(uint80 amount, uint16 duration, uint16 timePassed, uint16 timeAgoStarted, address beneficiary)
        internal
        returns (SingleAddressLinearERC20TransferVesting vesting, uint96 expected)
    {
        vm.assume(duration != 0 && block.timestamp > timeAgoStarted);
        vesting = new SingleAddressLinearERC20TransferVesting(
            erc20, amount, uint64(block.timestamp - timeAgoStarted), duration, beneficiary
        );
        if (timePassed > duration) {
            expected = amount;
        } else {
            expected = ((timePassed + timeAgoStarted) * uint96(amount)) / duration;
        }
        vm.warp(block.timestamp + timePassed);
        erc20.mint(address(vesting), type(uint256).max);
    }

    function test_linearVesting(
        uint80 amount,
        uint16 duration,
        uint16 timePassed,
        uint16 timeAgoStarted,
        address beneficiary
    ) public {
        (SingleAddressLinearERC20TransferVesting vesting, uint96 expected) =
            getVesting(amount, duration, timePassed, timeAgoStarted, beneficiary);
        vm.assertEq(vesting.releasable(), expected);
    }

    function test_erc20minted(
        uint80 amount,
        uint16 duration,
        uint16 timePassed,
        uint16 timeAgoStarted,
        address beneficiary
    ) public {
        (SingleAddressLinearERC20TransferVesting vesting, uint96 expected) =
            getVesting(amount, duration, timePassed, timeAgoStarted, beneficiary);
        vesting.release();
        vm.assertEq(erc20.balanceOf(beneficiary), expected);
    }

    function test_beforeStart(uint80 amount, uint16 duration, uint16 startsIn, address beneficiary) public {
        vm.assume(duration != 0);
        SingleAddressLinearERC20TransferVesting vesting = new SingleAddressLinearERC20TransferVesting(
            erc20, amount, uint64(block.timestamp + startsIn), duration, beneficiary
        );
        vm.assertEq(vesting.releasable(), 0);
    }

    function test_beforeStart(uint96 amount, uint64 start, uint64 duration, address beneficiary) public {
        SingleAddressLinearERC20TransferVesting vesting =
            new SingleAddressLinearERC20TransferVesting(erc20, amount, start, duration, beneficiary);
        vm.assertEq(vesting.beneficiary(), beneficiary);
    }
}
