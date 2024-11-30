// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./IERC20.sol";

abstract contract ERC20 is IERC20 {
    address owner;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address account => uint256 balance) public balanceOf;
    mapping(address owner => mapping(address spender => uint256 amount)) public override allowance;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "not an owner!");
        _;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(to != address(0));
        require(amount <= balanceOf[msg.sender]);

        return _transfer(msg.sender, to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];

        require(amount <= balanceOf[from]);
        require(amount <= allowed);
        require(to != address(0));

        allowance[from][msg.sender] = allowed - amount;
            
        return _transfer(from, to, amount);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0));

        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        uint256 balance = balanceOf[from];

        unchecked {
            balanceOf[from] -= balance;
        }

        balanceOf[to] += amount;

        emit Transfer(from, to, amount);

        return true;
    }

    function _mint(address to, uint256 amount) public onlyOwner {
        totalSupply += amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) external onlyOwner {
        balanceOf[from] -= amount;

        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}