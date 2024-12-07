// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {Bridge} from "../src/Bridge.sol";
import {CatToken} from "../src/Token.sol";

contract CounterTest is Test {
    Bridge bridge;
    CatToken token;

    address owner = makeAddr("owner");
    address user = makeAddr("user");

    function setUp() public {
        token = new CatToken();
        bridge = new Bridge(address(token));

        // Allocate tokens to "alice"
        vm.prank(owner);
        token.transfer(user, 100 ether); // Transfer tokens to user
    }

    function testLockTokens() public {
        vm.startPrank(user);

        // Approve Bridge to spend user tokens
        token.approve(address(bridge), 50 ether);

        // Lock tokens on the bridge
        bridge.lockTokens(50 ether, "Polygon");

        // Check balances
        assertEq(token.balanceOf(user), 50 ether, "User balance should decrease by 50 tokens");
        assertEq(token.balanceOf(address(bridge)), 50 ether, "Bridge balance should increase by 50 tokens");

        vm.stopPrank();
    }

    function testMintTokens() public {
        vm.startPrank(owner);

        // Mint tokens on the target chain
        bridge.mintTokens(user, 30 ether);

        // Check receiver balance
        assertEq(token.balanceOf(user), 30 ether, "Receiver should have 30 minted tokens");

        vm.stopPrank();
    }

    function testBurnTokens() public {
        vm.startPrank(user);

        // Approve and burn tokens
        token.approve(address(bridge), 20 ether);
        bridge.burnTokens(20 ether, "BSC");

        // Check balances
        assertEq(token.balanceOf(user), 80 ether, "User balance should decrease by 20 tokens");
        vm.stopPrank();
    }

    function testReleaseTokens() public {
        vm.startPrank(owner);

        // Release tokens back to the user
        bridge.releaseTokens(user, 50 ether);

        // Check balances
        assertEq(token.balanceOf(user), 150 ether, "User should have received released tokens");

        vm.stopPrank();
    }
}
