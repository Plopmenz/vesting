// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import {
    SingleBeneficiaryLinearERC20MintVesting,
    SingleBeneficiaryLinearERC20MintVestingStandalone
} from "../src/SingleBeneficiaryLinearERC20MintVesting.sol";
import {ERC20Mock, IERC20Mintable} from "./mocks/ERC20Mock.sol";

contract SingleBeneficiaryLinearERC20MintVestingTest is Test {
    ERC20Mock public erc20;

    function setUp() public {
        erc20 = new ERC20Mock();
    }

    function getVesting(uint96 amount, uint16 duration, uint16 timePassed, uint16 timeAgoStarted, address beneficiary)
        internal
        returns (SingleBeneficiaryLinearERC20MintVesting vesting, uint128 expected)
    {
        vm.assume(duration != 0 && block.timestamp > timeAgoStarted && beneficiary != address(0));
        vesting = new SingleBeneficiaryLinearERC20MintVestingStandalone(
            erc20, amount, uint64(block.timestamp - timeAgoStarted), duration, beneficiary
        );
        if (timePassed > duration) {
            expected = amount;
        } else {
            expected = ((timePassed + timeAgoStarted) * uint128(amount)) / duration;
        }
        vm.warp(block.timestamp + timePassed);
    }

    function test_linearVesting(
        uint96 amount,
        uint16 duration,
        uint16 timePassed,
        uint16 timeAgoStarted,
        address beneficiary
    ) public {
        (SingleBeneficiaryLinearERC20MintVesting vesting, uint128 expected) =
            getVesting(amount, duration, timePassed, timeAgoStarted, beneficiary);
        vm.assertEq(vesting.releasable(), expected);
    }

    function test_release(uint96 amount, uint16 duration, uint16 timePassed, uint16 timeAgoStarted, address beneficiary)
        public
    {
        (SingleBeneficiaryLinearERC20MintVesting vesting, uint128 expected) =
            getVesting(amount, duration, timePassed, timeAgoStarted, beneficiary);
        vesting.release();
        vm.assertEq(erc20.balanceOf(beneficiary), expected);
        vm.assertEq(vesting.released(), expected);
        vm.assertEq(vesting.releasable(), 0);
    }

    function test_beforeStart(uint96 amount, uint16 duration, uint16 startsIn, address beneficiary) public {
        vm.assume(duration != 0);
        SingleBeneficiaryLinearERC20MintVesting vesting = new SingleBeneficiaryLinearERC20MintVestingStandalone(
            erc20, amount, uint64(block.timestamp + startsIn), duration, beneficiary
        );
        vm.assertEq(vesting.releasable(), 0);
    }

    function test_init(IERC20Mintable token, uint128 amount, uint64 start, uint64 duration, address beneficiary)
        public
    {
        SingleBeneficiaryLinearERC20MintVesting vesting =
            new SingleBeneficiaryLinearERC20MintVestingStandalone(token, amount, start, duration, beneficiary);
        vm.assertEq(address(vesting.token()), address(token));
        vm.assertEq(vesting.amount(), amount);
        vm.assertEq(vesting.start(), start);
        vm.assertEq(vesting.duration(), duration);
        vm.assertEq(vesting.beneficiary(), beneficiary);
    }
}
