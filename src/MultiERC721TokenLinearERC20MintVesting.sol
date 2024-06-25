// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "../lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import {MultiTokenLinearVesting} from "./vesting/extensions/MultiTokenLinearVesting.sol";
import {ERC721OwnerBeneficiary, IERC721} from "./vesting/ERC721OwnerBeneficiary.sol";
import {ERC20MintReward, IERC20Mintable} from "./rewards/ERC20MintReward.sol";

contract MultiERC721TokenLinearERC20MintVesting is MultiTokenLinearVesting, ERC721OwnerBeneficiary, ERC20MintReward {
    function __MultiERC721TokenLinearERC20MintVesting_init(
        IERC20Mintable _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        IERC721 _ownerToken
    ) internal {
        __MultiTokenLinearVesting_init(_amount, _start, _duration);
        __ERC721OwnerBeneficiary_init(_ownerToken);
        __ERC20MintReward_init(_token);
    }
}

contract MultiERC721TokenLinearERC20MintVestingStandalone is MultiERC721TokenLinearERC20MintVesting {
    constructor(IERC20Mintable _token, uint128 _amount, uint64 _start, uint64 _duration, IERC721 _onwerToken) {
        __MultiERC721TokenLinearERC20MintVesting_init(_token, _amount, _start, _duration, _onwerToken);
    }
}

contract MultiERC721TokenLinearERC20MintVestingProxy is Initializable, MultiERC721TokenLinearERC20MintVesting {
    constructor() {
        _disableInitializers();
    }

    function initialize(IERC20Mintable _token, uint128 _amount, uint64 _start, uint64 _duration, IERC721 _onwerToken)
        external
        initializer
    {
        __MultiERC721TokenLinearERC20MintVesting_init(_token, _amount, _start, _duration, _onwerToken);
    }
}
