// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import {
    MerkleAddressLinearERC20TransferVesting,
    MerkleAddressLinearERC20TransferVestingStandalone
} from "../src/MerkleAddressLinearERC20TransferVesting.sol";
import {ERC20Mock, IERC20} from "./mocks/ERC20Mock.sol";

import {Merkle} from "../lib/murky/src/Merkle.sol";

contract MerkleAddressLinearERC20TransferVestingTest is Test {
    ERC20Mock public erc20;

    struct VestingInfo {
        uint80 amount;
        uint16 duration;
        uint16 timePassed;
        uint16 timeAgoStarted;
    }

    struct MerkleInfo {
        uint8 merkleIndex;
        address[] additionalMerkleItems;
    }

    function setUp() public {
        erc20 = new ERC20Mock();
    }

    function getVesting(VestingInfo memory info, bytes32 merkletreeRoot)
        internal
        returns (MerkleAddressLinearERC20TransferVesting vesting, uint96 expected)
    {
        vm.assume(info.duration != 0 && block.timestamp > info.timeAgoStarted);
        vesting = new MerkleAddressLinearERC20TransferVestingStandalone(
            erc20, info.amount, uint64(block.timestamp - info.timeAgoStarted), info.duration, merkletreeRoot
        );
        if (info.timePassed > info.duration) {
            expected = info.amount;
        } else {
            expected = ((info.timePassed + info.timeAgoStarted) * uint96(info.amount)) / info.duration;
        }
        vm.warp(block.timestamp + info.timePassed);
        erc20.mint(address(vesting), type(uint256).max);
    }

    function release(VestingInfo memory info, address beneficiary, MerkleInfo memory merkleInfo)
        internal
        returns (MerkleAddressLinearERC20TransferVesting vesting, uint96 expected)
    {
        vm.assume(
            merkleInfo.additionalMerkleItems.length != 0
                && merkleInfo.merkleIndex <= merkleInfo.additionalMerkleItems.length && beneficiary != address(0)
        );

        Merkle m = new Merkle();
        bytes32[] memory data = new bytes32[](merkleInfo.additionalMerkleItems.length + 1);
        for (uint256 i; i < data.length; i++) {
            if (i == merkleInfo.merkleIndex) {
                data[i] = keccak256(bytes.concat(keccak256(abi.encode(beneficiary))));
            } else {
                uint256 index = i;
                if (i > merkleInfo.merkleIndex) {
                    index -= 1;
                }
                data[i] = keccak256(bytes.concat(keccak256(abi.encode(merkleInfo.additionalMerkleItems[index]))));
            }
        }
        bytes32 root = m.getRoot(data);

        (vesting, expected) = getVesting(info, root);
        bytes32[] memory proof = m.getProof(data, merkleInfo.merkleIndex);
        vm.assertEq(vesting.verifyAddress(proof, beneficiary), true);
        vesting.release(proof, beneficiary);
    }

    function test_linearVesting(VestingInfo memory info, address beneficiary) public {
        (MerkleAddressLinearERC20TransferVesting vesting, uint96 expected) = getVesting(info, bytes32(0));
        vm.assertEq(vesting.releasable(beneficiary), expected);
    }

    function test_release(VestingInfo memory info, address beneficiary, MerkleInfo memory merkleInfo) public {
        (MerkleAddressLinearERC20TransferVesting vesting, uint96 expected) = release(info, beneficiary, merkleInfo);
        vm.assertEq(erc20.balanceOf(beneficiary), expected);
        vm.assertEq(vesting.released(beneficiary), expected);
        vm.assertEq(vesting.releasable(beneficiary), 0);
    }

    function test_beforeStart(uint80 amount, uint16 duration, uint16 startsIn, address beneficiary) public {
        vm.assume(duration != 0);
        MerkleAddressLinearERC20TransferVesting vesting = new MerkleAddressLinearERC20TransferVestingStandalone(
            erc20, amount, uint64(block.timestamp + startsIn), duration, bytes32(0)
        );
        erc20.mint(address(vesting), type(uint256).max);
        vm.assertEq(vesting.releasable(beneficiary), 0);
    }

    function test_init(IERC20 token, uint128 amount, uint64 start, uint64 duration, bytes32 merkletreeRoot) public {
        MerkleAddressLinearERC20TransferVesting vesting =
            new MerkleAddressLinearERC20TransferVestingStandalone(token, amount, start, duration, merkletreeRoot);
        vm.assertEq(address(vesting.token()), address(token));
        vm.assertEq(vesting.amount(), amount);
        vm.assertEq(vesting.start(), start);
        vm.assertEq(vesting.duration(), duration);
        vm.assertEq(vesting.merkletreeRoot(), merkletreeRoot);
    }

    function test_notPartOfTree(VestingInfo memory info, address beneficiary, MerkleInfo memory merkleInfo) public {
        vm.assume(
            merkleInfo.additionalMerkleItems.length > 1
                && merkleInfo.merkleIndex < merkleInfo.additionalMerkleItems.length
        );
        vm.assume(merkleInfo.additionalMerkleItems[merkleInfo.merkleIndex] != beneficiary);

        Merkle m = new Merkle();
        bytes32[] memory data = new bytes32[](merkleInfo.additionalMerkleItems.length);
        for (uint256 i; i < data.length; i++) {
            data[i] = keccak256(bytes.concat(keccak256(abi.encode(merkleInfo.additionalMerkleItems[i]))));
        }
        bytes32 root = m.getRoot(data);

        (MerkleAddressLinearERC20TransferVesting vesting,) = getVesting(info, root);
        bytes32[] memory proof = m.getProof(data, merkleInfo.merkleIndex);
        vm.assertEq(vesting.verifyAddress(proof, beneficiary), false);
        vm.expectRevert();
        vesting.release(proof, beneficiary);
    }
}
