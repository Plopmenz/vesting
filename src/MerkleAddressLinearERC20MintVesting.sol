// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20MintReward, IERC20Mintable} from "./rewards/ERC20MintReward.sol";
import {MerkleAddressLinearVesting} from "./vesting/MerkleAddressLinearVesting.sol";

import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract MerkleAddressLinearERC20MintVesting is ERC20MintReward, MerkleAddressLinearVesting {
    constructor(IERC20Mintable _token, uint96 _amount, uint64 _start, uint64 _duration, bytes32 _merkletreeRoot)
        ERC20MintReward(_token)
        MerkleAddressLinearVesting(_amount, _start, _duration, _merkletreeRoot)
    {}

    /// @notice Getter for the address that will receive the tokens.
    function beneficiary(address _account) public view virtual override returns (address) {
        return _account;
    }

    function reward(address _beneficiary, uint96 _amount)
        internal
        virtual
        override(ERC20MintReward, MerkleAddressLinearVesting)
    {
        super.reward(_beneficiary, _amount);
    }
}