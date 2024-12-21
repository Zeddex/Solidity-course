// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {MockRandomizer} from "./mocks/MockRandomizer.sol";
import {DiceGame} from "../src/DiceGame.sol";
import {DiceGame_Updated} from "../src/DiceGame_Updated.sol";

contract DiceGameTest is Test {
    DiceGame public diceGame;
    DiceGame_Updated public diceGameUpd;
    MockRandomizer public mockRandomizer;

    address player = makeAddr("player");
    address player2 = makeAddr("player2");

    function setUp() public {
        // Replace the randomizer
        vm.etch(address(0xB5f954C9a37b59796dD59A693323e438f9c8cBAA), address(mockRandomizer).code);

        mockRandomizer = new MockRandomizer();
        diceGame = new DiceGame(address(mockRandomizer));
        diceGameUpd = new DiceGame_Updated(address(mockRandomizer));

        diceGame.fundContract{value: 5 ether}();
        diceGameUpd.fundContract{value: 5 ether}();
    }

    function testFailWithdrawalAsNotOwner() public {
        vm.prank(player);
        diceGame.withdraw();
    }

    function testFailWithdrawalAsNotOwner_Updated() public {
        vm.prank(player);
        diceGameUpd.withdraw();
    }

    function testWrongValueAmount() public {
        vm.expectRevert(bytes("Wrong amount"));

        diceGame.placeBet{value: 0}(5);
    }

    function testWrongValueAmount_Updated() public {
        vm.expectRevert(DiceGame_Updated.WrongAmount.selector);

        diceGameUpd.placeBet{value: 0}(5);
    }

    function testInvalidNumber() public {
        vm.expectRevert(bytes("Invalid number"));

        hoax(player);
        diceGame.placeBet{value: 1000}(123);
    }

    function testInvalidNumber_Updated() public {
        vm.expectRevert(DiceGame_Updated.InvalidNumber.selector);

        hoax(player);
        diceGameUpd.placeBet{value: 1000}(123);
    }

    function testBetCover() public {
        vm.expectRevert(bytes("Cannot cover the bet"));

        hoax(player);
        diceGame.placeBet{value: 10 ether}(5);
    }

    function testBetCover_Updated() public {
        vm.expectRevert(DiceGame_Updated.CannotCoverBet.selector);

        hoax(player);
        diceGameUpd.placeBet{value: 10 ether}(5);
    }

    function testProcessBet() public {
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
        randomNumbers[0] = uint256(simulateNumber - 1); // real conctract gives numbers from 0, mocked from 1
        mockRandomizer.mockFulfillRandomWords(requestId, randomNumbers); // Fulfill the mock request

        diceGame.processBet(requestId);

        assertEq(address(diceGame).balance, contractStartBalance - betAmount); // Contract balance decreases
        assertEq(player.balance, playerStartBalance + betAmount); // Player should win 2x the bet

        vm.stopPrank();
    }

    function testProcessBet_Updated() public {
        uint256 betAmount = 0.01 ether;
        uint256 playerStartBalance = 1 ether;
        uint256 contractStartBalance = address(diceGameUpd).balance;

        vm.deal(player, playerStartBalance);

        vm.startPrank(player);

        // Place a bet
        uint8 guessedNumber = 3;
        diceGameUpd.placeBet{value: betAmount}(guessedNumber);

        // Retrieve the requestId from the mock randomizer
        uint256 requestId = mockRandomizer.currentRequestId();

        // Mock fulfillment of random words
        uint256[] memory randomNumbers = new uint256[](1);
        uint8 simulateNumber = 3;
        randomNumbers[0] = uint256(simulateNumber - 1); // real conctract gives numbers from 0, mocked from 1
        mockRandomizer.mockFulfillRandomWords(requestId, randomNumbers); // Fulfill the mock request

        diceGameUpd.processBet(requestId);

        assertEq(address(diceGameUpd).balance, contractStartBalance - betAmount); // Contract balance decreases
        assertEq(player.balance, playerStartBalance + betAmount); // Player should win 2x the bet

        vm.stopPrank();
    }

    function testPlayerLose() public {
        uint256 betAmount = 0.01 ether;
        uint256 playerStartBalance = 1 ether;
        uint256 contractStartBalance = address(diceGame).balance;

        vm.deal(player, playerStartBalance);

        vm.startPrank(player);

        uint8 guessedNumber = 3;
        diceGame.placeBet{value: betAmount}(guessedNumber);

        uint256 requestId = mockRandomizer.currentRequestId();

        uint256[] memory randomNumbers = new uint256[](1);
        uint8 simulateNumber = 6;
        randomNumbers[0] = uint256(simulateNumber - 1); // real conctract gives numbers from 0, mocked from 1
        mockRandomizer.mockFulfillRandomWords(requestId, randomNumbers);

        diceGame.processBet(requestId);

        assertEq(player.balance, playerStartBalance - betAmount);
        assertEq(address(diceGame).balance, contractStartBalance + betAmount);

        vm.stopPrank();
    }

    function testPlayerLose_Updated() public {
        uint256 betAmount = 0.01 ether;
        uint256 playerStartBalance = 1 ether;
        uint256 contractStartBalance = address(diceGameUpd).balance;

        vm.deal(player, playerStartBalance);

        vm.startPrank(player);

        uint8 guessedNumber = 3;
        diceGameUpd.placeBet{value: betAmount}(guessedNumber);

        uint256 requestId = mockRandomizer.currentRequestId();

        uint256[] memory randomNumbers = new uint256[](1);
        uint8 simulateNumber = 6;
        randomNumbers[0] = uint256(simulateNumber - 1); // real conctract gives numbers from 0, mocked from 1
        mockRandomizer.mockFulfillRandomWords(requestId, randomNumbers);

        diceGameUpd.processBet(requestId);

        assertEq(player.balance, playerStartBalance - betAmount);
        assertEq(address(diceGameUpd).balance, contractStartBalance + betAmount);

        vm.stopPrank();
    }

    function testOnlyPlayerCanProcessBet_Updated() public {
        hoax(player);
        diceGameUpd.placeBet{value: 0.01 ether}(3);

        uint256 requestId = mockRandomizer.currentRequestId();

        vm.expectRevert(DiceGame_Updated.NotTheBetOwner.selector);

        vm.prank(player2);
        diceGameUpd.processBet(requestId);
    }
}
