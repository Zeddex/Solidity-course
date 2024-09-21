// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./ERC20.sol";
import "./CustomToken.sol";

/// @notice Gas unoptimized demo contract
contract CustomShopUnoptimized {
    IERC20 public token;
    address public owner;
    uint[] public payments; // unoptimized

    event Bought(address indexed _buyer, uint256 _amount);
    event Sold(address indexed _seller, uint256 _amount);

    modifier onlyOwner {
        require(msg.sender == owner, "Not an owner!");
        _;
    }

    constructor() {
        token = new CustomToken(address(this));
        owner = msg.sender;
    }

    /// @notice 1 token = 1 wei
    receive() external payable {
        uint256 tokensToBuy = msg.value;    // unoptimized

        require(tokensToBuy > 0, "Not enough funds!");
        require(token.balanceOf(address(this)) >= tokensToBuy, "Not enough tokens!");

        token.transfer(msg.sender, tokensToBuy);

        payments.push(tokensToBuy); // unoptimized

        emit Bought(msg.sender, tokensToBuy);
    }

    function tokenBalance(address account) public view returns(uint256) {
        return token.balanceOf(account);
    }

    function sell(uint256 _amountToSell) external {
        address from = msg.sender; // unoptimized

        require(_amountToSell > 0 &&
        token.balanceOf(from) >= _amountToSell, 
        "Incorrect amount!");
        
        token.transferFrom(from, address(this), _amountToSell);
        
        (bool success, ) = from.call{value: _amountToSell}("");
        require(success, "Failed to send ETH!");

        emit Sold(from, _amountToSell);
    }

    function withdrawAll() external onlyOwner {
        uint256 contractBalance = address(this).balance;    // unoptimized

        (bool success, ) = owner.call{value: contractBalance}("");
        require(success, "Failed to withdraw!");
    }
}