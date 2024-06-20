// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Initializable} from "../lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

import {ERC20TransferReward, IERC20} from "./rewards/ERC20TransferReward.sol";
import {SingleAccountLinearVesting} from "./vesting/SingleAccountLinearVesting.sol";

library SingleAddressLinearERC20TransferVestingStorage {
    bytes32 private constant SLOT = keccak256("single.address.linear.erc20.transfer.vesting.plopmenz");

    struct Storage {
        address receiver;
    }

    function getStorage() internal pure returns (Storage storage $) {
        bytes32 slot = SLOT;
        assembly {
            $.slot := slot
        }
    }
}

contract SingleAddressLinearERC20TransferVesting is ERC20TransferReward, SingleAccountLinearVesting {
    function __SingleAddressLinearERC20TransferVesting_init(
        IERC20 _token,
        uint128 _amount,
        uint64 _start,
        uint64 _duration,
        address _receiver
    ) internal {
        SingleAddressLinearERC20TransferVestingStorage.Storage storage $ =
            SingleAddressLinearERC20TransferVestingStorage.getStorage();
        __SingleAccountLinearVesting_init(_amount, _start, _duration);
        __ERC20TransferReward_init(_token);
        $.receiver = _receiver;
    }

    /// @notice Getter for the address that will receive the tokens.
    function beneficiary() public view virtual override returns (address) {
        SingleAddressLinearERC20TransferVestingStorage.Storage storage $ =
            SingleAddressLinearERC20TransferVestingStorage.getStorage();
        return $.receiver;
    }

    function reward(address _beneficiary, uint128 _amount)
        internal
        virtual
        override(ERC20TransferReward, SingleAccountLinearVesting)
    {
        super.reward(_beneficiary, _amount);
    }
}

contract SingleAddressLinearERC20TransferVestingStandalone is SingleAddressLinearERC20TransferVesting {
    constructor(IERC20 _token, uint128 _amount, uint64 _start, uint64 _duration, address _receiver) {
        __SingleAddressLinearERC20TransferVesting_init(_token, _amount, _start, _duration, _receiver);
    }
}

contract SingleAddressLinearERC20TransferVestingProxy is Initializable, SingleAddressLinearERC20TransferVesting {
    constructor() {
        _disableInitializers();
    }

    function initialize(IERC20 _token, uint128 _amount, uint64 _start, uint64 _duration, address _receiver)
        external
        initializer
    {
        __SingleAddressLinearERC20TransferVesting_init(_token, _amount, _start, _duration, _receiver);
    }
}
