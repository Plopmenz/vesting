// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20Mintable} from "./IERC20Mintable.sol";

library ERC20MintRewardStorage {
    bytes32 private constant SLOT = keccak256("erc20.mint.reward.vesting.plopmenz");

    struct Storage {
        IERC20Mintable token;
    }

    function getStorage() internal pure returns (Storage storage $) {
        bytes32 slot = SLOT;
        assembly {
            $.slot := slot
        }
    }
}

abstract contract ERC20MintReward {
    event ERC20Released(address beneficiary, uint256 amount);

    function __ERC20MintReward_init(IERC20Mintable _token) internal {
        ERC20MintRewardStorage.Storage storage $ = ERC20MintRewardStorage.getStorage();
        $.token = _token;
    }

    function token() external view returns (IERC20Mintable) {
        ERC20MintRewardStorage.Storage storage $ = ERC20MintRewardStorage.getStorage();
        return $.token;
    }

    /// @notice Release the tokens that have already vested.
    function reward(address _beneficiary, uint128 _amount) internal virtual {
        ERC20MintRewardStorage.Storage storage $ = ERC20MintRewardStorage.getStorage();
        emit ERC20Released(_beneficiary, _amount);
        $.token.mint(_beneficiary, _amount);
    }
}
