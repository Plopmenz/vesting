// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "../lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import {MerkleTokenLinearVesting} from "./vesting/extensions/MerkleTokenLinearVesting.sol";
import {ERC721OwnerBeneficiary, IERC721} from "./vesting/ERC721OwnerBeneficiary.sol";
import {ERC20MintReward, IERC20Mintable} from "./rewards/ERC20MintReward.sol";

contract MerkleERC721TokenLinearERC20MintVesting is
    MerkleTokenLinearVesting,
    ERC721OwnerBeneficiary,
    ERC20MintReward
{
    function __MerkleERC721TokenLinearERC20MintVesting_init(
        IERC20Mintable _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        bytes32 _merkletreeRoot,
        IERC721 _ownerToken
    ) internal {
        __MerkleTokenLinearVesting_init(_amount, _start, _duration, _merkletreeRoot);
        __ERC721OwnerBeneficiary_init(_ownerToken);
        __ERC20MintReward_init(_token);
    }
}

contract MerkleERC721TokenLinearERC20MintVestingStandalone is MerkleERC721TokenLinearERC20MintVesting {
    constructor(
        IERC20Mintable _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        bytes32 _merkletreeRoot,
        IERC721 _ownerToken
    ) {
        __MerkleERC721TokenLinearERC20MintVesting_init(_token, _amount, _start, _duration, _merkletreeRoot, _ownerToken);
    }
}

contract MerkleERC721TokenLinearERC20MintVestingProxy is Initializable, MerkleERC721TokenLinearERC20MintVesting {
    constructor() {
        _disableInitializers();
    }

    function initialize(
        IERC20Mintable _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        bytes32 _merkletreeRoot,
        IERC721 _ownerToken
    ) external initializer {
        __MerkleERC721TokenLinearERC20MintVesting_init(_token, _amount, _start, _duration, _merkletreeRoot, _ownerToken);
    }
}
