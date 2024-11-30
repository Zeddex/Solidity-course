// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.26;

contract Implementation2 {
    uint256 public count;

    /// @notice Selector of the function: 0x371303c0
    function inc() external {
        count += 1;
    }

    /// @notice Selector of the function: 0xb3bcfa82
    function dec() external {
        count -= 1;
    }
}