// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.26;

import "./IERC20Permit.sol";
import "./ERC20.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../node_modules/@openzeppelin/contracts/utils/cryptography/EIP712.sol";

abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    bytes32 private constant _PERMIT_TYPEHASH = keccak256(
      "Permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)"  
    );

    constructor(string memory name) EIP712(name, "1") {}

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual {
      require(deadline >= block.timestamp, "deadline expired!");

      bytes32 structHash = keccak256(
        abi.encode(
          _PERMIT_TYPEHASH,
          owner,
          spender,
          value,
          _useNonce(owner),
          deadline
        )
      );
        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);

        require(signer == owner, "not an owner!");

        _approve(owner, spender, value);    
    }

    function _useNonce(address owner) internal virtual returns(uint256 current) {
      Counters.Counter storage nonce = _nonces[owner];

      current = nonce.current();

      nonce.increment();
    }

    function nonces(address owner) external view returns(uint256) {
      return _nonces[owner].current();
    }

    function DOMAIN_SEPARATOR() external view returns(bytes32) {
      return _domainSeparatorV4();
    }
}