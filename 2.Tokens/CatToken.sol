// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.19;

import "./ERC20.sol";

contract CatToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Cat", "CAT", 18) {
        _mint(msg.sender, initialSupply);
    }
}