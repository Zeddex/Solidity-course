// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IRandomizer {
    function requestRandomWords() external returns (uint256 requestId);

    function getRequestStatus(uint256 _requestId)
        external
        view
        returns (bool fulfilled, uint256[] memory randomWords);
}

contract DiceGame_Updated {
    uint8 private constant MIN_NUMBER = 1;
    uint8 private constant MAX_NUMBER = 6;

    address public immutable owner;
    address private immutable randomizer;

    mapping(uint256 betId => Bet) public bets;

    struct Bet {
        address player;
        uint256 amount;
        uint8 guessedNumber;
    }

    event BetPlaced(address indexed player, uint256 amount, uint8 guessedNumber);

    event BetResult(address indexed player, bool won, uint256 payout, uint8 randomNumber);

    event FundsReceived(address indexed sender, uint256 amount);

    error NotAnOwner();
    error InvalidNumber();
    error WrongAmount();
    error CannotCoverBet();
    error BetNotFound(uint256 betId);
    error RandomNumberNotAvailable();
    error PayoutFailed();
    error WithdrawalFailed();
    error NotTheBetOwner();
    error ZeroAddress();

    constructor(address _randomizer) {
        owner = msg.sender;

        if (_randomizer == address(0)) {
            revert ZeroAddress();
        }

        randomizer = _randomizer;
    }

    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert NotAnOwner();
        }
        _;
    }

    function placeBet(uint8 guessedNumber) external payable returns (uint256 betId) {
        if (msg.value == 0) {
            revert WrongAmount();
        }

        if (guessedNumber < MIN_NUMBER || guessedNumber > MAX_NUMBER) {
            revert InvalidNumber();
        }

        if (msg.value * 2 > address(this).balance) {
            revert CannotCoverBet();
        }

        betId = IRandomizer(randomizer).requestRandomWords();

        bets[betId] = Bet({player: msg.sender, amount: msg.value, guessedNumber: guessedNumber});

        emit BetPlaced(msg.sender, msg.value, guessedNumber);
    }

    function processBet(uint256 betId) external {
        Bet memory bet = bets[betId];

        // Ensure only the player can resolve their bet
        if (bet.player != msg.sender) {
            revert NotTheBetOwner();
        }

        if (bet.amount == 0) {
            revert BetNotFound(betId);
        }

        // Call the randomizer
        (bool exists, uint256[] memory randomWords) = IRandomizer(randomizer).getRequestStatus(betId);

        if (!exists) {
            revert RandomNumberNotAvailable();
        }

        // Random number between 1 and 6
        uint8 randomNumber = uint8((randomWords[0] % MAX_NUMBER) + 1);
        bool won = (randomNumber == bet.guessedNumber);

        if (won) {
            uint256 payout = bet.amount * 2;

            (bool success,) = bet.player.call{value: payout}("");

            if (!success) {
                revert PayoutFailed();
            }

            emit BetResult(bet.player, true, payout, randomNumber);
        } else {
            emit BetResult(bet.player, false, 0, randomNumber);
        }

        // Clean up bet data
        delete bets[betId];
    }

    function withdraw() external onlyOwner {
        uint256 contractBalance = address(this).balance;

        (bool success,) = owner.call{value: contractBalance}("");

        if (!success) {
            revert WithdrawalFailed();
        }
    }

    function fundContract() external payable {
        if (msg.value == 0) {
            revert WrongAmount();
        }

        emit FundsReceived(msg.sender, msg.value);
    }
}
