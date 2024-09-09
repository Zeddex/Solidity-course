// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.26;

import "./ERC20.sol";
import "./ERC20Permit.sol";

contract CatToken is ERC20, ERC20Permit {
    constructor() ERC20("CatToken", "CAT") ERC20Permit("CatToken") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }
}