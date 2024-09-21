// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.26;

import "./IAccessControl.sol";

abstract contract AccessControl is IAccessControl {
    struct RoleData {
        mapping(address => bool) members;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant SUPER_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    modifier onlyAdmin {
        _checkRole(SUPER_ADMIN_ROLE);
        _;
    }

    function hasRole(bytes32 role, address account) internal view virtual returns(bool){
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) public view virtual {
        _checkRole(role, msg.sender);
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert("no such role");
        }
    }

    function grantRole(bytes32 role, address account) public virtual onlyAdmin {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual onlyAdmin {
        _revokeRole(role, account);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;

            emit RoleGranted(role, account, msg.sender);
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;

            emit RoleRevoked(role, account, msg.sender);
        }
    }
}