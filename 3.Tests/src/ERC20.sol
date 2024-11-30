// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    address owner;
    uint256 public totalSupply;
    string public name;
    string public symbol;

    mapping(address account => uint256 balance) balances;
    mapping(address owner => mapping(address spender => uint256 amount)) allowances;

    constructor(string memory _name, string memory _symbol, uint256 initialSupply, address _owner) {
        name = _name;
        symbol = _symbol;
        owner = _owner;

        mint(initialSupply, owner);
    }

    modifier enoughTokens(address _owner, uint256 _amount) {
        require(balanceOf(_owner) >= _amount, "not enough tokens");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "not an owner!");
        _;
    }

    function decimals() external pure returns(uint8) {
        return 18;
    }

    function balanceOf(address account) public view returns(uint256) {
        return balances[account];
    }

    function allowance(address _owner, address spender) public view returns(uint256 remaining) {
        return allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) public returns(bool success) {
        require(spender != address(0), "zero address!");

        return _approve(msg.sender, spender, amount);
    }

    function _approve(address _owner, address spender, uint256 amount) internal virtual returns(bool success) {
        allowances[_owner][spender] = amount;

        emit Approval(_owner, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) external enoughTokens(msg.sender, amount) returns (bool success) {        
        require(to != address(0), "zero address!");

        _transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public enoughTokens(from, amount) returns(bool success) {
        require(allowances[from][to] >= amount, "check allowance!");
        require(from != address(0), "zero address!");

        allowances[from][msg.sender] -= amount;
            
        _transfer(from, to, amount);

        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        balances[from] -= amount;
        balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function mint(uint256 amount, address to) public onlyOwner {        
        balances[to] += amount;
        totalSupply += amount;

        emit Transfer(address(0), to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner {        
        totalSupply -= amount;
        _transfer(from, address(0), amount);

        emit Transfer(from, address(0), amount);
    }
}