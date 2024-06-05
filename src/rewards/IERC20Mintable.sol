// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IERC20Mintable is IERC20 {
    /// @notice Mints tokens to a specific account.
    /// @param account The account that will receive the minted tokens.
    /// @param amount The amount of tokens to mint.
    /// @dev Should be locked behind a permission/restriction.
    function mint(address account, uint256 amount) external;
}
