// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20MintReward, IERC20Mintable} from "./rewards/ERC20MintReward.sol";
import {MultiTokenLinearVesting} from "./vesting/MultiTokenLinearVesting.sol";

import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract MultiERC721TokenLinearERC20MintVesting is ERC20MintReward, MultiTokenLinearVesting {
    IERC721 public immutable ownerToken;

    constructor(IERC20Mintable _token, uint96 _amount, uint64 _start, uint64 _duration, IERC721 _ownerToken)
        ERC20MintReward(_token)
        MultiTokenLinearVesting(_amount, _start, _duration)
    {
        ownerToken = _ownerToken;
    }

    /// @notice Getter for the address that will receive the tokens.
    function beneficiary(uint256 _tokenId) public view virtual override returns (address) {
        return ownerToken.ownerOf(_tokenId);
    }

    function reward(address _beneficiary, uint96 _amount)
        internal
        virtual
        override(ERC20MintReward, MultiTokenLinearVesting)
    {
        super.reward(_beneficiary, _amount);
    }
}
