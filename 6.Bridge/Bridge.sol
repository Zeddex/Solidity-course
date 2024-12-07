// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {CatToken} from "./Token.sol";

event TokensLocked(address indexed user, uint256 amount, string targetChain, address receiver);

event TokensReleased(address indexed user, uint256 amount);

event TokensMinted(address indexed user, uint256 amount);

event TokensBurned(address indexed user, uint256 amount, string sourceChain, address receiver);

contract Bridge is Ownable {
    IERC20 public token;

    constructor(address _token) Ownable(msg.sender) {
        token = IERC20(_token);
    }

    /**
     * @dev Lock tokens on the source chain
     * Emits TokensLocked event
     */
    function lockTokens(uint256 amount, string memory targetChain) external {
        require(amount > 0, "Amount must be greater than 0");

        token.transferFrom(msg.sender, address(this), amount);

        emit TokensLocked(msg.sender, amount, targetChain, msg.sender);
    }

    /**
     * @dev Release tokens on the source chain
     * Callable only by the bridge owner
     * Emits TokensReleased event
     */
    function releaseTokens(address user, uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");

        token.transfer(user, amount);

        emit TokensReleased(user, amount);
    }

    /**
     * @dev Mint tokens on the target chain
     * Callable only by the bridge owner
     * Emits TokensMinted event
     */
    function mintTokens(address user, uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");

        CatToken(address(token)).mint(user, amount);

        emit TokensMinted(user, amount);
    }

    /**
     * @dev Burn tokens on the target chain.
     * Emits TokensBurned event.
     */
    function burnTokens(uint256 amount, string memory sourceChain) external {
        require(amount > 0, "Amount must be greater than 0");

        CatToken(address(token)).burnFrom(msg.sender, amount);

        emit TokensBurned(msg.sender, amount, sourceChain, msg.sender);
    }
}
