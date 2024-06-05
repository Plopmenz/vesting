// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SafeERC20, IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract ERC20TransferReward {
    event ERC20Released(address beneficiary, uint256 amount);

    IERC20 public immutable token;

    constructor(IERC20 _token) {
        token = _token;
    }

    /// @notice Release the tokens that have already vested.
    function reward(address _beneficiary, uint96 _amount) internal virtual {
        emit ERC20Released(_beneficiary, _amount);
        SafeERC20.safeTransfer(token, _beneficiary, _amount);
    }
}
