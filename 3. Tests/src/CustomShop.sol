// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./ERC20.sol";
import "./CustomToken.sol";

contract CustomShop {
    IERC20 public token;
    address public owner;

    event Bought(address indexed _buyer, uint256 _amount);
    event Sold(address indexed _seller, uint256 _amount);

    constructor() {
        token = new CustomToken(address(this));
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Not an owner!");
        _;
    }

    receive() external payable {
        uint256 tokensToBuy = msg.value; // 1 token = 1 wei

        require(tokensToBuy > 0, "Not enough funds!");
        require(token.balanceOf(address(this)) >= tokensToBuy, "Not enough tokens!");

        token.transfer(msg.sender, tokensToBuy);

        emit Bought(msg.sender, tokensToBuy);
    }

    function tokenBalance(address account) public view returns(uint256) {
        return token.balanceOf(account);
    }

    function sell(uint256 _amountToSell) external {
        require(_amountToSell > 0 &&
        token.balanceOf(msg.sender) >= _amountToSell, 
        "Incorrect amount!");
        
        token.transferFrom(msg.sender, address(this), _amountToSell);
        
        (bool success, ) = msg.sender.call{value: _amountToSell}("");
        require(success, "Failed to send ETH!");

        emit Sold(msg.sender, _amountToSell);
    }

    function withdrawAll() external onlyOwner {
        uint256 contractBalance = address(this).balance;

        (bool success, ) = owner.call{value: contractBalance}("");
        require(success, "Failed to withdraw");
    }
}