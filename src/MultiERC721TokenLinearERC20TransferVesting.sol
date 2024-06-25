// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "../lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import {MultiTokenLinearVesting} from "./vesting/extensions/MultiTokenLinearVesting.sol";
import {ERC721OwnerBeneficiary, IERC721} from "./vesting/ERC721OwnerBeneficiary.sol";
import {ERC20TransferReward, IERC20} from "./rewards/ERC20TransferReward.sol";

contract MultiERC721TokenLinearERC20TransferVesting is
    MultiTokenLinearVesting,
    ERC721OwnerBeneficiary,
    ERC20TransferReward
{
    function __MultiERC721TokenLinearERC20TransferVesting_init(
        IERC20 _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        IERC721 _ownerToken
    ) internal {
        __MultiTokenLinearVesting_init(_amount, _start, _duration);
        __ERC721OwnerBeneficiary_init(_ownerToken);
        __ERC20TransferReward_init(_token);
    }
}

contract MultiERC721TokenLinearERC20TransferVestingStandalone is MultiERC721TokenLinearERC20TransferVesting {
    constructor(IERC20 _token, uint128 _amount, uint64 _start, uint64 _duration, IERC721 _ownerToken) {
        __MultiERC721TokenLinearERC20TransferVesting_init(_token, _amount, _start, _duration, _ownerToken);
    }
}

contract MultiERC721TokenLinearERC20TransferVestingProxy is
    Initializable,
    MultiERC721TokenLinearERC20TransferVesting
{
    constructor() {
        _disableInitializers();
    }

    function initialize(IERC20 _token, uint128 _amount, uint64 _start, uint64 _duration, IERC721 _ownerToken)
        external
        initializer
    {
        __MultiERC721TokenLinearERC20TransferVesting_init(_token, _amount, _start, _duration, _ownerToken);
    }
}
