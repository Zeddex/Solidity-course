// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {CatToken} from "../src/Token.sol";

contract TokenTest is Test {
    CatToken token;

    address owner = address(this);
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        token = new CatToken();
        token.transfer(alice, 100 ether); // Transfer some tokens to "alice"
    }

    function testInitialSupply() public view {
        uint256 initialSupply = 10000 ether;
        assertEq(token.balanceOf(owner), initialSupply - 100 ether, "Owner should have remaining tokens");
        assertEq(token.balanceOf(alice), 100 ether, "Alice should have received 100 tokens");
    }

    function testTransfer() public {
        vm.startPrank(alice);
        token.transfer(bob, 50 ether);
        assertEq(token.balanceOf(bob), 50 ether, "Recipient should have received 50 tokens");
        assertEq(token.balanceOf(alice), 50 ether, "Alice should have remaining balance of 50 tokens");
        vm.stopPrank();
    }

    function testMint() public {
        token.mint(bob, 100 ether);
        assertEq(token.balanceOf(bob), 100 ether, "Minted balance is incorrect");
    }
}
