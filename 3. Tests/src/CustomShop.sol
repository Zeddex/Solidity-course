// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./ERC20.sol";
import "./CustomToken.sol";

/// @title Shop contract allows to buy and sell tokens
/// @notice A simple shop demo
contract CustomShop {
    IERC20 public token;
    address public owner;

    /// @notice Emitted when tokens are bought
    /// @param _buyer buyer's address
    /// @param _buyer amounts of tokens
    event Bought(address indexed _buyer, uint256 _amount);

    /// @notice Emitted when tokens are sold
    /// @param _seller seller's address
    /// @param _amount amounts of tokens
    event Sold(address indexed _seller, uint256 _amount);

    constructor() {
        token = new CustomToken(address(this));
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Not an owner!");
        _;
    }

    /// @notice Receive ether and send tokens back
    receive() external payable {
        // 1 token = 1 wei
        uint256 tokensToBuy = msg.value;

        require(tokensToBuy > 0, "Not enough funds!");
        require(token.balanceOf(address(this)) >= tokensToBuy, "Not enough tokens!");

        token.transfer(msg.sender, tokensToBuy);

        emit Bought(msg.sender, tokensToBuy);
    }

    function tokenBalance(address account) public view returns(uint256) {
        return token.balanceOf(account);
    }

    /// @notice Sell tokens from the wallet
    /// @param _amountToSell amounts of tokens to sell
    function sell(uint256 _amountToSell) external {
        require(_amountToSell > 0 &&
        token.balanceOf(msg.sender) >= _amountToSell, 
        "Incorrect amount!");
        
        // get tokens from seller
        token.transferFrom(msg.sender, address(this), _amountToSell);
        
        // send ether to seller
        (bool success, ) = msg.sender.call{value: _amountToSell}("");
        require(success, "Failed to send ETH!");

        emit Sold(msg.sender, _amountToSell);
    }

    /// @notice Withdraw funds from the contract
    function withdrawAll() external onlyOwner {
        uint256 contractBalance = address(this).balance;

        (bool success, ) = owner.call{value: contractBalance}("");
        require(success, "Failed to withdraw");
    }
}