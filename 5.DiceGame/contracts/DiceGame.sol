// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Randomizer} from "./Randomizer.sol";

event BetPlaced(address indexed player, uint256 amount, uint8 guessedNumber);

event BetResult(address indexed player, bool won, uint256 payout, uint8 randomNumber);

contract DiceGame {
    address public owner;
    uint256 public balance;
    Randomizer random = Randomizer(0xB5f954C9a37b59796dD59A693323e438f9c8cBAA);

    struct Bet {
        address player;
        uint256 amount;
        uint8 guessedNumber;
    }

    mapping(uint256 requestId => Bet) public bets;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Not an owner");
        _;
    }

    function placeBet(uint8 guessedNumber) external payable {
        require(guessedNumber >= 1 && guessedNumber <= 6, "Invalid number");
        require(msg.value > 0, "Wrong amount");
        require(msg.value * 2 <= address(this).balance, "Cannot cover the bet");

        uint256 requestId = random.requestRandomWords();

        bets[requestId] = Bet({player: msg.sender, amount: msg.value, guessedNumber: guessedNumber});

        emit BetPlaced(msg.sender, msg.value, guessedNumber);
    }

    function processBet(uint256 requestId) external {
        Bet memory bet = bets[requestId];
        require(bet.amount > 0, "Bet not found");

        // Get the random number
        (bool exists, uint256[] memory randomWords) = random.getRequestStatus(requestId);
        require(exists, "Random number not available");

        // Random number between 1 and 6
        uint8 randomNumber = uint8((randomWords[0] % 6) + 1);
        bool won = (randomNumber == bet.guessedNumber);

        if (won) {
            uint256 payout = bet.amount * 2;
            balance -= payout;

            (bool success,) = bet.player.call{value: payout}("");
            require(success, "Payout failed");

            emit BetResult(bet.player, true, payout, randomNumber);
        } else {
            emit BetResult(bet.player, false, 0, randomNumber);
        }

        // Clean up bet data
        delete bets[requestId];
    }

    function fundContract() public payable {}

    function withdraw() external onlyOwner {
        uint256 contractBalance = address(this).balance;

        (bool success,) = owner.call{value: contractBalance}("");
        require(success, "Withdrawal failed");
    }
}
