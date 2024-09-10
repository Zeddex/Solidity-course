// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./ERC20.sol";

contract CustomToken is ERC20 {
    constructor(address owner) ERC20("CustomToken", "CSTM", 1000000, owner) {}
}