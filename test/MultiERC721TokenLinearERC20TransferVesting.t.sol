// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import {MultiERC721TokenLinearERC20TransferVesting} from "../src/MultiERC721TokenLinearERC20TransferVesting.sol";
import {ERC20Mock, IERC20Mintable} from "./mocks/ERC20Mock.sol";
import {ERC721Mock, IERC721} from "./mocks/ERC721Mock.sol";

contract MultiERC721TokenLinearERC20TransferVestingTest is Test {
    ERC20Mock public erc20;
    ERC721Mock public erc721;

    function setUp() public {
        erc20 = new ERC20Mock();
        erc721 = new ERC721Mock();
    }

    function getVesting(uint80 amount, uint16 duration, uint16 timePassed, uint16 timeAgoStarted)
        internal
        returns (MultiERC721TokenLinearERC20TransferVesting vesting, uint96 expected)
    {
        vm.assume(duration != 0 && block.timestamp > timeAgoStarted);
        vesting = new MultiERC721TokenLinearERC20TransferVesting(
            erc20, amount, uint64(block.timestamp - timeAgoStarted), duration, erc721
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
        uint256 tokenId,
        uint80 amount,
        uint16 duration,
        uint16 timePassed,
        uint16 timeAgoStarted,
        address beneficiary
    ) public {
        vm.assume(beneficiary.code.length == 0 && beneficiary != address(0)); // ERC721 receiver
        (MultiERC721TokenLinearERC20TransferVesting vesting, uint96 expected) =
            getVesting(amount, duration, timePassed, timeAgoStarted);
        erc721.mint(beneficiary, tokenId);
        vm.assertEq(vesting.releasable(tokenId), expected);
    }

    function test_erc20minted(
        uint256 tokenId,
        uint80 amount,
        uint16 duration,
        uint16 timePassed,
        uint16 timeAgoStarted,
        address beneficiary
    ) public {
        vm.assume(beneficiary.code.length == 0 && beneficiary != address(0)); // ERC721 receiver
        (MultiERC721TokenLinearERC20TransferVesting vesting, uint96 expected) =
            getVesting(amount, duration, timePassed, timeAgoStarted);
        erc721.mint(beneficiary, tokenId);
        vesting.release(tokenId);
        vm.assertEq(erc20.balanceOf(beneficiary), expected);
    }

    function test_beforeStart(uint256 tokenId, uint80 amount, uint16 duration, uint16 startsIn, address beneficiary)
        public
    {
        vm.assume(beneficiary.code.length == 0 && beneficiary != address(0)); // ERC721 receiver
        vm.assume(duration != 0);
        MultiERC721TokenLinearERC20TransferVesting vesting = new MultiERC721TokenLinearERC20TransferVesting(
            erc20, amount, uint64(block.timestamp + startsIn), duration, erc721
        );
        erc20.mint(address(vesting), type(uint256).max);
        erc721.mint(beneficiary, tokenId);
        vm.assertEq(vesting.releasable(tokenId), 0);
    }

    function test_beneficiary(uint256 tokenId, uint96 amount, uint64 start, uint64 duration, address beneficiary)
        public
    {
        vm.assume(beneficiary.code.length == 0 && beneficiary != address(0)); // ERC721 receiver
        MultiERC721TokenLinearERC20TransferVesting vesting =
            new MultiERC721TokenLinearERC20TransferVesting(erc20, amount, start, duration, erc721);
        erc20.mint(address(vesting), type(uint256).max);
        erc721.mint(beneficiary, tokenId);
        vm.assertEq(vesting.beneficiary(tokenId), beneficiary);
    }
}
