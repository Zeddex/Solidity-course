// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {CatToken} from "../src/Token.sol";

contract CounterTest is Test {
    CatToken token;

    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        token = new CatToken();
        vm.prank(owner);
        token.transfer(alice, 100 ether); // Transfer some tokens to "alice"
    }

    function testInitialSupply() public view {
        assertEq(token.balanceOf(owner), 2000 ether - 100 ether, "Owner should have remaining tokens");
        assertEq(token.balanceOf(alice), 100 ether, "Alice should have received 100 tokens");
    }

    function testTransfer() public {
        vm.startPrank(alice);
        token.transfer(bob, 50 ether);
        assertEq(token.balanceOf(bob), 50 ether, "Recipient should have received 50 tokens");
        assertEq(token.balanceOf(alice), 50 ether, "Alice should have remaining balance of 50 tokens");
        vm.stopPrank();
    }
}
