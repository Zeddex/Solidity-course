// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.26;

library StorageSlot {
    struct AddressSlot {
        address value;
    }

    function getAddressSlot(bytes32 _slot) internal pure returns(AddressSlot storage ret)
    {
        assembly {
            ret.slot := _slot
        }
    }
}

contract Proxy {
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    bytes32 private constant ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    uint256 public count;

    constructor() {
        _setAdmin(msg.sender);
    }

    modifier isAdmin {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    /// @notice Set new implementation
    /// @param _implementation Address of a new implementation
    function upgradeTo(address _implementation) external isAdmin {
        _setImplementation(_implementation);
    }

    function _getAdmin() private view returns(address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    function _setAdmin(address _admin) private {
        require(_admin != address(0), "admin is zero address!");

        StorageSlot.getAddressSlot(ADMIN_SLOT).value = _admin;
    }

    function changeAdmin(address _admin) external isAdmin {
        _setAdmin(_admin);
    }

    function _getImplementation() private view returns(address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address _implementation) private {
        require(_implementation.code.length > 0, "implementation is not a contract!");

        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
    }

    /// @notice Delegatecall to implementation address and check the result
    /// @param _implementation Address of a new implementation
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

    receive() external payable {}

    fallback() external payable {
        _fallback();
    }

    function _fallback() private {
        _delegate(_getImplementation());
    }
}