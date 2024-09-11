// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.26;

contract Implementation1 {
    uint256 public count;

    // 0x371303c0
    function inc() external {
        count += 1;
    }
}