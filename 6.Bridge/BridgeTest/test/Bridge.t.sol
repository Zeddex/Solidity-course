// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {Bridge} from "../src/Bridge.sol";
import {CatToken} from "../src/Token.sol";

contract BridgeTest is Test {
    Bridge bridge;
    CatToken token;

    address user = makeAddr("user");
    uint256 userStartBalance = 100 ether;

    function setUp() public {
        token = new CatToken();
        bridge = new Bridge(address(token));

        // Transfer ownership of the token contract to the bridge contract
        vm.startPrank(token.owner());
        token.transferOwnership(address(bridge));
        vm.stopPrank();

        // Allocate tokens to user
        token.transfer(user, userStartBalance);
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
        // Mint tokens on the target chain
        bridge.mintTokens(user, 30 ether);

        // Check receiver balance
        assertEq(token.balanceOf(user), userStartBalance + 30 ether, "Receiver should have 30 minted tokens");
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
        // Lock tokens to release them after
        vm.startPrank(user);

        // Approve Bridge to spend user tokens
        token.approve(address(bridge), 50 ether);

        // Lock tokens on the bridge
        bridge.lockTokens(50 ether, "Polygon");

        vm.stopPrank();

        // Release tokens back to the user
        bridge.releaseTokens(user, 50 ether);

        // Check balances
        assertEq(token.balanceOf(user), userStartBalance, "User should have received released tokens");
    }
}
