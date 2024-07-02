// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TokenBeneficiary} from "./TokenBeneficiary.sol";

import {ERC721OwnerBeneficiaryStorage, IERC721} from "../storage/ERC721OwnerBeneficiaryStorage.sol";

abstract contract ERC721OwnerBeneficiary is TokenBeneficiary {
    event ERC721OwnerBeneficiaryCreated(IERC721 indexed ownerToken);

    function __ERC721OwnerBeneficiary_init(IERC721 _ownerToken) internal {
        emit ERC721OwnerBeneficiaryCreated(_ownerToken);
        ERC721OwnerBeneficiaryStorage.Storage storage $ = ERC721OwnerBeneficiaryStorage.getStorage();
        $.ownerToken = _ownerToken;
    }

    function ownerToken() public view virtual returns (IERC721) {
        ERC721OwnerBeneficiaryStorage.Storage storage $ = ERC721OwnerBeneficiaryStorage.getStorage();
        return $.ownerToken;
    }

    function beneficiary(uint256 _tokenId) public view virtual override returns (address) {
        ERC721OwnerBeneficiaryStorage.Storage storage $ = ERC721OwnerBeneficiaryStorage.getStorage();
        return $.ownerToken.ownerOf(_tokenId);
    }
}
