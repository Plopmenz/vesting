// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20MintReward, IERC20Mintable} from "./rewards/ERC20MintReward.sol";
import {MerkleTokenLinearVesting} from "./vesting/MerkleTokenLinearVesting.sol";

import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract MerkleERC721TokenLinearERC20MintVesting is ERC20MintReward, MerkleTokenLinearVesting {
    IERC721 public immutable ownerToken;

    constructor(
        IERC20Mintable _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        bytes32 _merkletreeRoot,
        IERC721 _ownerToken
    ) {
        __ERC20MintReward_init(_token);
        __MerkleTokenLinearVesting_init(_amount, _start, _duration, _merkletreeRoot);
        ownerToken = _ownerToken;
    }

    /// @notice Getter for the address that will receive the tokens.
    function beneficiary(uint256 _tokenId) public view virtual override returns (address) {
        return ownerToken.ownerOf(_tokenId);
    }

    function reward(address _beneficiary, uint128 _amount)
        internal
        virtual
        override(ERC20MintReward, MerkleTokenLinearVesting)
    {
        super.reward(_beneficiary, _amount);
    }
}
