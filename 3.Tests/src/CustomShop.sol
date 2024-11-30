// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./ERC20.sol";
import "./CustomToken.sol";

/// @title Shop contract allows to buy and sell tokens
/// @notice A simple shop demo
contract CustomShop {
    IERC20 public token;
    address public owner;
    mapping(address => uint256) public payments;

    /// @notice Emitted when tokens are bought
    /// @param _buyer buyer's address
    /// @param _buyer amounts of tokens
    event Bought(address indexed _buyer, uint256 _amount);

    /// @notice Emitted when tokens are sold
    /// @param _seller seller's address
    /// @param _amount amounts of tokens
    event Sold(address indexed _seller, uint256 _amount);

    error IncorrectAmount(uint256);
    error OutOfTokens();
    error NotEnoughFunds();

    modifier onlyOwner {
        require(msg.sender == owner, "Not an owner!");
        _;
    }

    constructor() {
        token = new CustomToken(address(this));
        owner = msg.sender;
    }

    /// Receive ether and send tokens back
    /// @notice 1 token = 1 wei
    receive() external payable {
        if (msg.value == 0) {
            revert OutOfTokens();
        }

        if (token.balanceOf(address(this)) < msg.value) {
            revert OutOfTokens();
        }

        token.transfer(msg.sender, msg.value);

        payments[msg.sender] = msg.value;

        emit Bought(msg.sender, msg.value);
    }

    function tokenBalance(address account) public view returns(uint256) {
        return token.balanceOf(account);
    }

    /// Sell tokens from the wallet
    /// @param _amountToSell amounts of tokens to sell
    function sell(uint256 _amountToSell) external {
        if (_amountToSell < 0  &&
        token.balanceOf(msg.sender) < _amountToSell) {
            revert IncorrectAmount(_amountToSell);
        }
        
        // get tokens from seller
        token.transferFrom(msg.sender, address(this), _amountToSell);
        
        // send ether to seller
        (bool success, ) = msg.sender.call{value: _amountToSell}("");
        require(success, "Failed to send ETH!");

        emit Sold(msg.sender, _amountToSell);
    }

    /// Withdraw funds from the contract
    function withdrawAll() external onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Failed to withdraw!");
    }
}