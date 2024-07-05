// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Reward} from "./Reward.sol";

import {SafeERC20, IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20RewardStorage} from "../storage/ERC20RewardStorage.sol";

abstract contract ERC20TransferReward is Reward {
    event ERC20Released(address indexed beneficiary, uint256 amount);

    function __ERC20TransferReward_init(IERC20 _token) internal {
        ERC20RewardStorage.Storage storage $ = ERC20RewardStorage.getStorage();
        $.token = _token;
    }

    function token() public view virtual returns (IERC20) {
        ERC20RewardStorage.Storage storage $ = ERC20RewardStorage.getStorage();
        return $.token;
    }

    function _reward(address _beneficiary, uint256 _amount) internal virtual override {
        emit ERC20Released(_beneficiary, _amount);
        SafeERC20.safeTransfer(token(), _beneficiary, _amount);
    }
}
