// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "../lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import {MerkleAddressLinearVesting} from "./vesting/extensions/MerkleAddressLinearVesting.sol";
import {ERC20MintReward, IERC20Mintable} from "./rewards/ERC20MintReward.sol";

contract MerkleAddressLinearERC20MintVesting is MerkleAddressLinearVesting, ERC20MintReward {
    function __MerkleAddressLinearERC20MintVesting_init(
        IERC20Mintable _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        bytes32 _merkletreeRoot
    ) internal {
        __MerkleAddressLinearVesting_init(_amount, _start, _duration, _merkletreeRoot);
        __ERC20MintReward_init(_token);
    }
}

contract MerkleAddressLinearERC20MintVestingStandalone is MerkleAddressLinearERC20MintVesting {
    constructor(IERC20Mintable _token, uint128 _amount, uint64 _start, uint64 _duration, bytes32 _merkletreeRoot) {
        __MerkleAddressLinearERC20MintVesting_init(_token, _amount, _start, _duration, _merkletreeRoot);
    }
}

contract MerkleAddressLinearERC20MintVestingProxy is Initializable, MerkleAddressLinearERC20MintVesting {
    constructor() {
        _disableInitializers();
    }

    function initialize(
        IERC20Mintable _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        bytes32 _merkletreeRoot
    ) external initializer {
        __MerkleAddressLinearERC20MintVesting_init(_token, _amount, _start, _duration, _merkletreeRoot);
    }
}
