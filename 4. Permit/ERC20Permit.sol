// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.26;

import "./IERC20Permit.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../node_modules/@openzeppelin/contracts/utils/cryptography/EIP712.sol";

absctract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counter for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    bytes private constant _PERMIT_TYPHASH = keccak256(
      "Permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)"  
    );

    constructor(string memory name) EIP712(name, "1") {}

    
}