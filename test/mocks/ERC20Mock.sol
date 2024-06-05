// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20Mintable} from "../../src/rewards/IERC20Mintable.sol";

contract ERC20Mock is ERC20, IERC20Mintable {
    constructor() ERC20("", "") {}

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }
}
