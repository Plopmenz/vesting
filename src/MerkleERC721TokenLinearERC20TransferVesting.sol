// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20TransferReward, IERC20} from "./rewards/ERC20TransferReward.sol";
import {MerkleTokenLinearVesting} from "./vesting/MerkleTokenLinearVesting.sol";

import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract MerkleERC721TokenLinearERC20TransferVesting is ERC20TransferReward, MerkleTokenLinearVesting {
    IERC721 public immutable ownerToken;

    constructor(
        IERC20 _token,
        uint96 _amount,
        uint64 _start,
        uint64 _duration,
        bytes32 _merkletreeRoot,
        IERC721 _ownerToken
    ) ERC20TransferReward(_token) MerkleTokenLinearVesting(_amount, _start, _duration, _merkletreeRoot) {
        ownerToken = _ownerToken;
    }

    /// @notice Getter for the address that will receive the tokens.
    function beneficiary(uint256 _tokenId) public view virtual override returns (address) {
        return ownerToken.ownerOf(_tokenId);
    }

    function reward(address _beneficiary, uint96 _amount)
        internal
        virtual
        override(ERC20TransferReward, MerkleTokenLinearVesting)
    {
        super.reward(_beneficiary, _amount);
    }
}
