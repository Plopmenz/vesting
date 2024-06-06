// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import {MerkleERC721TokenLinearERC20MintVesting} from "../src/MerkleERC721TokenLinearERC20MintVesting.sol";
import {ERC20Mock, IERC20Mintable} from "./mocks/ERC20Mock.sol";
import {ERC721Mock, IERC721} from "./mocks/ERC721Mock.sol";

import {Merkle} from "../lib/murky/src/Merkle.sol";

contract MerkleERC721TokenLinearERC20MintVestingTest is Test {
    ERC20Mock public erc20;
    ERC721Mock public erc721;

    struct VestingInfo {
        uint80 amount;
        uint16 duration;
        uint16 timePassed;
        uint16 timeAgoStarted;
    }

    struct MerkleInfo {
        uint8 merkleIndex;
        uint256[] additionalMerkleItems;
    }

    function setUp() public {
        erc20 = new ERC20Mock();
        erc721 = new ERC721Mock();
    }

    function getVesting(VestingInfo memory info, bytes32 merkletreeRoot)
        internal
        returns (MerkleERC721TokenLinearERC20MintVesting vesting, uint96 expected)
    {
        vm.assume(info.duration != 0 && block.timestamp > info.timeAgoStarted);
        vesting = new MerkleERC721TokenLinearERC20MintVesting(
            erc20, info.amount, uint64(block.timestamp - info.timeAgoStarted), info.duration, merkletreeRoot, erc721
        );
        if (info.timePassed > info.duration) {
            expected = info.amount;
        } else {
            expected = ((info.timePassed + info.timeAgoStarted) * uint96(info.amount)) / info.duration;
        }
        vm.warp(block.timestamp + info.timePassed);
    }

    function test_linearVesting(uint256 tokenId, VestingInfo memory info, address beneficiary) public {
        vm.assume(beneficiary.code.length == 0 && beneficiary != address(0)); // ERC721 receiver
        (MerkleERC721TokenLinearERC20MintVesting vesting, uint96 expected) = getVesting(info, bytes32(0));
        erc721.mint(beneficiary, tokenId);
        vm.assertEq(vesting.releasable(tokenId), expected);
    }

    function test_erc20minted(
        uint256 tokenId,
        VestingInfo memory info,
        address beneficiary,
        MerkleInfo memory merkleInfo
    ) public {
        vm.assume(beneficiary.code.length == 0 && beneficiary != address(0)); // ERC721 receiver
        vm.assume(
            merkleInfo.additionalMerkleItems.length != 0
                && merkleInfo.merkleIndex <= merkleInfo.additionalMerkleItems.length
        );

        Merkle m = new Merkle();
        bytes32[] memory data = new bytes32[](merkleInfo.additionalMerkleItems.length + 1);
        for (uint256 i; i < data.length; i++) {
            if (i == merkleInfo.merkleIndex) {
                data[i] = keccak256(bytes.concat(keccak256(abi.encode(tokenId))));
            } else {
                uint256 index = i;
                if (i > merkleInfo.merkleIndex) {
                    index -= 1;
                }
                data[i] = keccak256(bytes.concat(keccak256(abi.encode(merkleInfo.additionalMerkleItems[index]))));
            }
        }
        bytes32 root = m.getRoot(data);

        (MerkleERC721TokenLinearERC20MintVesting vesting, uint96 expected) = getVesting(info, root);
        erc721.mint(beneficiary, tokenId);
        bytes32[] memory proof = m.getProof(data, merkleInfo.merkleIndex);
        vm.assertEq(vesting.verifyTokenid(proof, tokenId), true);
        vesting.release(proof, tokenId);
        vm.assertEq(erc20.balanceOf(beneficiary), expected);
    }

    function test_beforeStart(uint256 tokenId, uint80 amount, uint16 duration, uint16 startsIn, address beneficiary)
        public
    {
        vm.assume(beneficiary.code.length == 0 && beneficiary != address(0)); // ERC721 receiver
        vm.assume(duration != 0);
        MerkleERC721TokenLinearERC20MintVesting vesting = new MerkleERC721TokenLinearERC20MintVesting(
            erc20, amount, uint64(block.timestamp + startsIn), duration, bytes32(0), erc721
        );
        erc721.mint(beneficiary, tokenId);
        vm.assertEq(vesting.releasable(tokenId), 0);
    }

    function test_beneficiary(uint256 tokenId, uint96 amount, uint64 start, uint64 duration, address beneficiary)
        public
    {
        vm.assume(beneficiary.code.length == 0 && beneficiary != address(0)); // ERC721 receiver
        MerkleERC721TokenLinearERC20MintVesting vesting =
            new MerkleERC721TokenLinearERC20MintVesting(erc20, amount, start, duration, bytes32(0), erc721);
        erc721.mint(beneficiary, tokenId);
        vm.assertEq(vesting.beneficiary(tokenId), beneficiary);
    }

    function test_notPartOfTree(
        uint256 tokenId,
        VestingInfo memory info,
        address beneficiary,
        MerkleInfo memory merkleInfo
    ) public {
        vm.assume(beneficiary.code.length == 0 && beneficiary != address(0)); // ERC721 receiver
        vm.assume(
            merkleInfo.additionalMerkleItems.length > 1
                && merkleInfo.merkleIndex < merkleInfo.additionalMerkleItems.length
        );
        vm.assume(merkleInfo.additionalMerkleItems[merkleInfo.merkleIndex] != tokenId);

        Merkle m = new Merkle();
        bytes32[] memory data = new bytes32[](merkleInfo.additionalMerkleItems.length);
        for (uint256 i; i < data.length; i++) {
            data[i] = keccak256(bytes.concat(keccak256(abi.encode(merkleInfo.additionalMerkleItems[i]))));
        }
        bytes32 root = m.getRoot(data);

        (MerkleERC721TokenLinearERC20MintVesting vesting,) = getVesting(info, root);
        erc721.mint(beneficiary, tokenId);
        bytes32[] memory proof = m.getProof(data, merkleInfo.merkleIndex);
        vm.assertEq(vesting.verifyTokenid(proof, tokenId), false);
        vm.expectRevert();
        vesting.release(proof, tokenId);
    }
}