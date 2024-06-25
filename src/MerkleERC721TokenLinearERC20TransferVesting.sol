// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "../lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import {MerkleTokenLinearVesting} from "./vesting/extensions/MerkleTokenLinearVesting.sol";
import {ERC721OwnerBeneficiary, IERC721} from "./vesting/ERC721OwnerBeneficiary.sol";
import {ERC20TransferReward, IERC20} from "./rewards/ERC20TransferReward.sol";

contract MerkleERC721TokenLinearERC20TransferVesting is
    MerkleTokenLinearVesting,
    ERC721OwnerBeneficiary,
    ERC20TransferReward
{
    function __MerkleERC721TokenLinearERC20TransferVesting_init(
        IERC20 _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        bytes32 _merkletreeRoot,
        IERC721 _ownerToken
    ) internal {
        __MerkleTokenLinearVesting_init(_amount, _start, _duration, _merkletreeRoot);
        __ERC721OwnerBeneficiary_init(_ownerToken);
        __ERC20TransferReward_init(_token);
    }
}

contract MerkleERC721TokenLinearERC20TransferVestingStandalone is MerkleERC721TokenLinearERC20TransferVesting {
    constructor(
        IERC20 _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        bytes32 _merkletreeRoot,
        IERC721 _ownerToken
    ) {
        __MerkleERC721TokenLinearERC20TransferVesting_init(
            _token, _amount, _start, _duration, _merkletreeRoot, _ownerToken
        );
    }
}

contract MerkleERC721TokenLinearERC20TransferVestingProxy is
    Initializable,
    MerkleERC721TokenLinearERC20TransferVesting
{
    constructor() {
        _disableInitializers();
    }

    function initialize(
        IERC20 _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        bytes32 _merkletreeRoot,
        IERC721 _ownerToken
    ) external initializer {
        __MerkleERC721TokenLinearERC20TransferVesting_init(
            _token, _amount, _start, _duration, _merkletreeRoot, _ownerToken
        );
    }
}
