// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Clones} from "../../lib/openzeppelin-contracts/contracts/proxy/Clones.sol";

import {
    SingleAddressLinearERC20TransferVesting,
    SingleAddressLinearERC20TransferVestingProxy,
    SingleAddressLinearERC20TransferVestingStandalone
} from "../SingleAddressLinearERC20TransferVesting.sol";
import {IERC20Mintable} from "../rewards/IERC20Mintable.sol";

contract JITSingleAddressLinearERC20TransferVestingManager is Ownable {
    event VestingCreated(address vesting, uint128 amount, uint64 start, uint64 duration, address receiver);

    IERC20Mintable immutable token;
    SingleAddressLinearERC20TransferVestingProxy immutable implementation;

    constructor(IERC20Mintable _token, address _admin) Ownable(_admin) {
        token = _token;
        implementation = new SingleAddressLinearERC20TransferVestingProxy();
    }

    function getAddress(uint128 _amount, uint64 _start, uint64 _duration, address _receiver)
        public
        view
        returns (address)
    {
        return Clones.predictDeterministicAddress(
            address(implementation), keccak256(abi.encodePacked(_amount, _start, _duration, _receiver))
        );
    }

    function createVestingClone(uint128 _amount, uint64 _start, uint64 _duration, address _receiver)
        external
        onlyOwner
    {
        address clone = Clones.cloneDeterministic(
            address(implementation), keccak256(abi.encodePacked(_amount, _start, _duration, _receiver))
        );
        SingleAddressLinearERC20TransferVestingProxy(clone).initialize(token, _amount, _start, _duration, _receiver);
        emit VestingCreated(clone, _amount, _start, _duration, _receiver);
    }

    function createVestingStandalone(uint128 _amount, uint64 _start, uint64 _duration, address _receiver)
        external
        onlyOwner
    {
        SingleAddressLinearERC20TransferVestingStandalone standalone = new SingleAddressLinearERC20TransferVestingStandalone{
            salt: keccak256(abi.encodePacked(_amount, _start, _duration, _receiver))
        }(token, _amount, _start, _duration, _receiver);
        emit VestingCreated(address(standalone), _amount, _start, _duration, _receiver);
    }

    function release(uint128 _amount, uint64 _start, uint64 _duration, address _receiver) external {
        SingleAddressLinearERC20TransferVesting vesting =
            SingleAddressLinearERC20TransferVesting(getAddress(_amount, _start, _duration, _receiver));
        uint128 releasable = vesting.releasable();
        token.mint(address(vesting), releasable);
        vesting.release();
    }
}
