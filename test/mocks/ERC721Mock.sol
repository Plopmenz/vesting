// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721, IERC721} from "../../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract ERC721Mock is ERC721 {
    constructor() ERC721("", "") {}

    function mint(address account, uint256 tokenId) external {
        _mint(account, tokenId);
    }
}
