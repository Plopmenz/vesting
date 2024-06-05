// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20Mintable} from "./IERC20Mintable.sol";

abstract contract ERC20MintReward {
    event ERC20Released(address beneficiary, uint256 amount);

    IERC20Mintable public immutable token;

    constructor(IERC20Mintable _token) {
        token = _token;
    }

    /// @notice Release the tokens that have already vested.
    function reward(address _beneficiary, uint96 _amount) internal virtual {
        emit ERC20Released(_beneficiary, _amount);
        token.mint(_beneficiary, _amount);
    }
}
