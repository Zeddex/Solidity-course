// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "./INativeBank.sol";

contract NativeBank is IBank {
    address public owner;
    mapping(address account => uint256 balance) private _balances;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    fallback() external payable {
        this.deposit();
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Not owner");
        _;
    }

    function balanceOf(address _account) external view returns (uint256) {
        return _balances[_account];
    }

    function deposit() external payable {
        _balances[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external {
        if (_amount == 0) {
            revert WithdrawalAmountZero(msg.sender);
        }
        if (_amount > _balances[msg.sender]) {
            revert WithdrawalAmountExceedsBalance({account: msg.sender, amount: _amount, balance: _balances[msg.sender]});
        }

        unchecked {
            _balances[msg.sender] -= _amount;
        }

        (bool success,) = msg.sender.call{value: _amount}("");
        require(success, "Failed to send Ether");

        emit Withdrawal(msg.sender, _amount);
    }

    function withdrawAll() external onlyOwner {
        uint256 contractBalance = address(this).balance;

        (bool success,) = owner.call{value: contractBalance}("");
        require(success, "Failed to send Ether");
    }
}
