// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.26;

library StorageSlot {
    struct AddressSlot {
        address value;
    }

    function getAddressSlot(bytes32 _slot) internal pure returns (AddressSlot storage ret)
    {
        assembly {
            ret.slot := _slot
        }
    }
}

contract Proxy {
    uint256 public count;

    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    bytes32 private constant ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    constructor() {
        _setAdmin(msg.sender);
    }

    modifier checkAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    function upgradeTo(address _implementation) external checkAdmin {
        _setImplementation(_implementation);
    }

    function changeAdmin(address _admin) external checkAdmin {
        _setAdmin(_admin);
    }

    function _setAdmin(address _admin) private {
        require(_admin != address(0), "admin is zero address!");
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = _admin;
    }

    function _getAdmin() private view returns(address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    function _setImplementation(address _implementation) private {
        require(_implementation.code.length > 0, "implementation is not a contract!");
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
    }

    function _getImplementation() private view returns(address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function _delegate(address _implementation) private {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _fallback() private {
        _delegate(_getImplementation());
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }
}

contract Version1 {
    uint256 public count;

    // 0x371303c0
    function inc() external {
        count += 1;
    }
}

contract Version2 {
    uint256 public count;

    // 0x371303c0
    function inc() external {
        count += 1;
    }

    // 0xb3bcfa82
    function dec() external {
        count -= 1;
    }
}