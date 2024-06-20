// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SafeERC20, IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

library ERC20TransferRewardStorage {
    bytes32 private constant SLOT = keccak256("erc20.transfer.reward.vesting.plopmenz");

    struct Storage {
        IERC20 token;
    }

    function getStorage() internal pure returns (Storage storage $) {
        bytes32 slot = SLOT;
        assembly {
            $.slot := slot
        }
    }
}

abstract contract ERC20TransferReward {
    event ERC20Released(address beneficiary, uint256 amount);

    function __ERC20TransferReward_init(IERC20 _token) internal {
        ERC20TransferRewardStorage.Storage storage $ = ERC20TransferRewardStorage.getStorage();
        $.token = _token;
    }

    function token() external view returns (IERC20) {
        ERC20TransferRewardStorage.Storage storage $ = ERC20TransferRewardStorage.getStorage();
        return $.token;
    }

    /// @notice Release the tokens that have already vested.
    function reward(address _beneficiary, uint128 _amount) internal virtual {
        ERC20TransferRewardStorage.Storage storage $ = ERC20TransferRewardStorage.getStorage();
        emit ERC20Released(_beneficiary, _amount);
        SafeERC20.safeTransfer($.token, _beneficiary, _amount);
    }
}
