// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Reward} from "./Reward.sol";

import {IERC20Mintable} from "./IERC20Mintable.sol";
import {ERC20RewardStorage} from "../storage/ERC20RewardStorage.sol";

abstract contract ERC20MintReward is Reward {
    event ERC20Released(address indexed beneficiary, uint256 amount);

    function __ERC20MintReward_init(IERC20Mintable _token) internal {
        ERC20RewardStorage.Storage storage $ = ERC20RewardStorage.getStorage();
        $.token = _token;
    }

    function token() public view virtual returns (IERC20Mintable) {
        ERC20RewardStorage.Storage storage $ = ERC20RewardStorage.getStorage();
        return IERC20Mintable(address($.token));
    }

    function _reward(address _beneficiary, uint256 _amount) internal virtual override {
        emit ERC20Released(_beneficiary, _amount);
        token().mint(_beneficiary, _amount);
    }
}
