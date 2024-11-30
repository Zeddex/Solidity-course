// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.26;

interface IAccessControl {
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;
}