// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.26;

contract Factory {
    Product[] public productAddresses;

    event ProductCreated(Product product);

    function create(string memory _productName) external {
        Product product = new Product(_productName);

        productAddresses.push(product);
        emit ProductCreated(product);
    }

    function create2(string memory _productName, bytes32 _salt) external {
        Product product = (new Product){salt: _salt}(_productName);

        productAddresses.push(product);
        emit ProductCreated(product);
    }

    function getProducts() external view returns(Product[] memory) {
        return productAddresses;
    }
}

contract Product {
    address public owner;
    address public productAddress;
    string public name;

    constructor(string memory _name) {
        name = _name;
        owner = msg.sender;
        productAddress = address(this);
    }
}