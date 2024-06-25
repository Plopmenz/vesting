// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "../lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import {MerkleAddressLinearVesting} from "./vesting/extensions/MerkleAddressLinearVesting.sol";
import {ERC20TransferReward, IERC20} from "./rewards/ERC20TransferReward.sol";

contract MerkleAddressLinearERC20TransferVesting is MerkleAddressLinearVesting, ERC20TransferReward {
    function __MerkleAddressLinearERC20TransferVesting_init(
        IERC20 _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        bytes32 _merkletreeRoot
    ) internal {
        __MerkleAddressLinearVesting_init(_amount, _start, _duration, _merkletreeRoot);
        __ERC20TransferReward_init(_token);
    }
}

contract MerkleAddressLinearERC20TransferVestingStandalone is MerkleAddressLinearERC20TransferVesting {
    constructor(IERC20 _token, uint128 _amount, uint64 _start, uint64 _duration, bytes32 _merkletreeRoot) {
        __MerkleAddressLinearERC20TransferVesting_init(_token, _amount, _start, _duration, _merkletreeRoot);
    }
}

contract MerkleAddressLinearERC20TransferVestingProxy is Initializable, MerkleAddressLinearERC20TransferVesting {
    constructor() {
        _disableInitializers();
    }

    function initialize(IERC20 _token, uint128 _amount, uint64 _start, uint64 _duration, bytes32 _merkletreeRoot)
        external
        initializer
    {
        __MerkleAddressLinearERC20TransferVesting_init(_token, _amount, _start, _duration, _merkletreeRoot);
    }
}
