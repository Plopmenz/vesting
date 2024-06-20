// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20TransferReward, IERC20} from "./rewards/ERC20TransferReward.sol";
import {MultiTokenLinearVesting} from "./vesting/MultiTokenLinearVesting.sol";

import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract MultiERC721TokenLinearERC20TransferVesting is ERC20TransferReward, MultiTokenLinearVesting {
    IERC721 public immutable ownerToken;

    constructor(IERC20 _token, uint128 _amount, uint64 _start, uint64 _duration, IERC721 _ownerToken) {
        __MultiTokenLinearVesting_init(_amount, _start, _duration);
        __ERC20TransferReward_init(_token);
        ownerToken = _ownerToken;
    }

    /// @notice Getter for the address that will receive the tokens.
    function beneficiary(uint256 _tokenId) public view virtual override returns (address) {
        return ownerToken.ownerOf(_tokenId);
    }

    function reward(address _beneficiary, uint128 _amount)
        internal
        virtual
        override(ERC20TransferReward, MultiTokenLinearVesting)
    {
        super.reward(_beneficiary, _amount);
    }
}
