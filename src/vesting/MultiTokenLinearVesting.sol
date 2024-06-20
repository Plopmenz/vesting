// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VestingUtils} from "./VestingUtils.sol";

library MultiTokenLinearVestingStorage {
    bytes32 private constant SLOT = keccak256("multi.token.linear.vesting.plopmenz");

    struct Storage {
        uint128 amount;
        uint64 start;
        uint64 duration;
        mapping(uint256 tokenId => uint128) released;
    }

    function getStorage() internal pure returns (Storage storage $) {
        bytes32 slot = SLOT;
        assembly {
            $.slot := slot
        }
    }
}

abstract contract MultiTokenLinearVesting {
    function __MultiTokenLinearVesting_init(uint128 _amount, uint64 _start, uint64 _duration) internal {
        MultiTokenLinearVestingStorage.Storage storage $ = MultiTokenLinearVestingStorage.getStorage();
        $.amount = _amount;
        $.start = _start;
        $.duration = _duration;
    }

    function amount() external view returns (uint128) {
        MultiTokenLinearVestingStorage.Storage storage $ = MultiTokenLinearVestingStorage.getStorage();
        return $.amount;
    }

    function start() external view returns (uint64) {
        MultiTokenLinearVestingStorage.Storage storage $ = MultiTokenLinearVestingStorage.getStorage();
        return $.start;
    }

    function duration() external view returns (uint64) {
        MultiTokenLinearVestingStorage.Storage storage $ = MultiTokenLinearVestingStorage.getStorage();
        return $.duration;
    }

    function released(uint256 _tokenId) external view returns (uint128) {
        MultiTokenLinearVestingStorage.Storage storage $ = MultiTokenLinearVestingStorage.getStorage();
        return $.released[_tokenId];
    }

    function reward(address _beneficiary, uint128 _amount) internal virtual;

    /// @notice Getter for the address that will receive the tokens.
    function beneficiary(uint256 _tokenId) public view virtual returns (address);

    /// @notice Getter for the amount of releasable tokens.
    function releasable(uint256 _tokenId) public view virtual returns (uint128) {
        MultiTokenLinearVestingStorage.Storage storage $ = MultiTokenLinearVestingStorage.getStorage();
        return uint128(VestingUtils.linearVesting($.start, $.duration, $.amount, uint64(block.timestamp)))
            - $.released[_tokenId];
    }

    /// @notice Release the tokens that have already vested.
    function release(uint256 _tokenId) public virtual {
        MultiTokenLinearVestingStorage.Storage storage $ = MultiTokenLinearVestingStorage.getStorage();
        address releaseBeneficiary = beneficiary(_tokenId);
        uint128 releaseAmount = releasable(_tokenId);
        $.released[_tokenId] += releaseAmount;
        reward(releaseBeneficiary, releaseAmount);
    }
}
