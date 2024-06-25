// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Managed} from "./Managed.sol";

import {ManagerStorage} from "../storage/ManagerStorage.sol";

abstract contract Manager is Managed {
    error SenderNotManager(address sender, address manager);

    function __Manager_init(address _manager) internal {
        ManagerStorage.Storage storage $ = ManagerStorage.getStorage();
        $.manager = _manager;
    }

    function manager() public view virtual returns (address) {
        ManagerStorage.Storage storage $ = ManagerStorage.getStorage();
        return $.manager;
    }

    modifier onlyManager() virtual override {
        if (msg.sender != manager()) {
            revert SenderNotManager(msg.sender, manager());
        }
        _;
    }
}
