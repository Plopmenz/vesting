// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vesting} from "./Vesting.sol";
import {TokenBeneficiary} from "./TokenBeneficiary.sol";

import {TokenReleasedStorage} from "../storage/TokenReleasedStorage.sol";

abstract contract TokenReleased is Vesting, TokenBeneficiary {
    function __TokenReleased_init() internal {}

    function released(uint256 _tokenId) public view virtual returns (uint256) {
        TokenReleasedStorage.Storage storage $ = TokenReleasedStorage.getStorage();
        return $.released[_tokenId];
    }

    function releasable(uint256 _tokenId) public view virtual returns (uint256) {
        return _vestingUnlocked() - released(_tokenId);
    }

    function _release(uint256 _tokenId) internal virtual {
        uint256 releaseAmount = releasable(_tokenId);
        TokenReleasedStorage.Storage storage $ = TokenReleasedStorage.getStorage();
        $.released[_tokenId] += releaseAmount;
        _reward(beneficiary(_tokenId), releaseAmount);
    }
}
