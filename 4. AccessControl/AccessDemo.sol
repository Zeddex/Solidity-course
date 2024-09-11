// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.26;

import "./AccessControl.sol";

contract AccessDemo is AccessControl {
    bytes32 public constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    bool isPaused = false;

    constructor() payable {
        _grantRole(SUPER_ADMIN_ROLE, msg.sender);
    }

    function pause() external onlyRole(ADMIN_ROLE) {
        isPaused = true;
    }

    function withdraw() external onlyRole(WITHDRAWER_ROLE) {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "withdrawal failed");
    }
}