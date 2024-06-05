// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20MintReward, IERC20Mintable} from "./rewards/ERC20MintReward.sol";
import {SingleAccountLinearVesting} from "./vesting/SingleAccountLinearVesting.sol";

contract SingleAddressLinearERC20MintVesting is ERC20MintReward, SingleAccountLinearVesting {
    address private immutable receiver;

    constructor(IERC20Mintable _token, uint96 _amount, uint64 _start, uint64 _duration, address _receiver)
        ERC20MintReward(_token)
        SingleAccountLinearVesting(_amount, _start, _duration)
    {
        receiver = _receiver;
    }

    /// @notice Getter for the address that will receive the tokens.
    function beneficiary() public view virtual override returns (address) {
        return receiver;
    }

    function reward(address _beneficiary, uint96 _amount)
        internal
        virtual
        override(ERC20MintReward, SingleAccountLinearVesting)
    {
        super.reward(_beneficiary, _amount);
    }
}
