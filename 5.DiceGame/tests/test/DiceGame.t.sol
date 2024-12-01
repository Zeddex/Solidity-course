// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {DiceGame} from "../src/DiceGame.sol";
import {MockRandomizer} from "./mocks/MockRandomizer.sol";

contract DiceGameTest is Test {
    DiceGame public diceGame;
    MockRandomizer public mockRandomizer;

    address player = makeAddr("player");

    function setUp() public {
        // Replace the randomizer
        vm.etch(address(0xB5f954C9a37b59796dD59A693323e438f9c8cBAA), address(mockRandomizer).code);

        mockRandomizer = new MockRandomizer();
        diceGame = new DiceGame(address(mockRandomizer));

        diceGame.fundContract{value: 5 ether}();
    }

    function testFail_WithdrawalAsNotOwner() public {
        vm.prank(player);
        diceGame.withdraw();
    }

    function test_WrongValueAmount() public {
        vm.expectRevert(bytes("Wrong amount"));

        diceGame.placeBet{value: 0}(5);
    }

    function test_InvalidNumber() public {
        vm.expectRevert(bytes("Invalid number"));

        hoax(player);
        diceGame.placeBet{value: 1000}(123);
    }

    function test_BetCover() public {
        vm.expectRevert(bytes("Cannot cover the bet"));

        hoax(player);
        diceGame.placeBet{value: 10 ether}(5);
    }

    function test_ProcessBet() public {
        uint256 betAmount = 0.01 ether;
        uint256 playerStartBalance = 1 ether;
        uint256 contractStartBalance = address(diceGame).balance;

        vm.deal(player, playerStartBalance);

        vm.startPrank(player);

        // Place a bet
        uint8 guessedNumber = 3;
        diceGame.placeBet{value: betAmount}(guessedNumber);

        // Retrieve the requestId from the mock randomizer
        uint256 requestId = mockRandomizer.currentRequestId();

        // Mock fulfillment of random words
        uint256[] memory randomNumbers = new uint256[](1);
        uint8 simulateNumber = 3;
        randomNumbers[0] = uint256(simulateNumber);
        mockRandomizer.mockFulfillRandomWords(requestId, randomNumbers); // Fulfill the mock request

        diceGame.processBet(requestId);

        assertEq(address(diceGame).balance, contractStartBalance - betAmount); // Contract balance decreases
        assertEq(player.balance, playerStartBalance + betAmount); // Player should win 2x the bet

        vm.stopPrank();
    }

    function test_PlayerLose() public {
        uint256 betAmount = 0.01 ether;
        uint256 playerStartBalance = 1 ether;
        uint256 contractStartBalance = address(diceGame).balance;

        vm.deal(player, playerStartBalance);

        vm.startPrank(player);

        uint8 guessedNumber = 3;
        diceGame.placeBet{value: betAmount}(guessedNumber);

        uint256 requestId = mockRandomizer.currentRequestId();

        uint256[] memory randomNumbers = new uint256[](1);
        uint8 simulateNumber = 1;
        randomNumbers[0] = uint256(simulateNumber);
        mockRandomizer.mockFulfillRandomWords(requestId, randomNumbers);

        diceGame.processBet(requestId);

        assertEq(player.balance, playerStartBalance - betAmount);
        assertEq(address(diceGame).balance, contractStartBalance + betAmount);

        vm.stopPrank();
    }
}
