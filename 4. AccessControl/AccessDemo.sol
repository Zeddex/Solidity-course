// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.26;

import "./AccessControl.sol";

contract AccessDemo is AccessControl {
    //keccak256 hashed roles
    bytes32 public constant WITHDRAWER_ROLE = 0x10dac8c06a04bec0b551627dad28bc00d6516b0caacd1c7b345fcdb5211334e4;
    bytes32 public constant ADMIN_ROLE = 0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775;

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