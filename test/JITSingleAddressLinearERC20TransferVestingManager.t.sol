// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import {JITSingleAddressLinearERC20TransferVestingManager} from
    "../src/managed/JITSingleAddressLinearERC20TransferVestingManager.sol";
import {ERC20Mock, IERC20Mintable} from "./mocks/ERC20Mock.sol";

contract JITSingleAddressLinearERC20TransferVestingManagerTest is Test {
    ERC20Mock public erc20;
    JITSingleAddressLinearERC20TransferVestingManager public manager;

    function setUp() public {
        erc20 = new ERC20Mock();
        manager = new JITSingleAddressLinearERC20TransferVestingManager(erc20, address(this));
    }

    function test_clone(uint128 _amount, uint64 _start, uint64 _duration, address _receiver) public {
        manager.createVestingClone(_amount, _start, _duration, _receiver);
    }

    function test_standalone(uint128 _amount, uint64 _start, uint64 _duration, address _receiver) public {
        manager.createVestingStandalone(_amount, _start, _duration, _receiver);
    }
}
