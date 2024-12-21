// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {DiceGame} from "../src/DiceGame.sol";

contract DiceGameScript is Script {
    DiceGame public diceGame;

    function run() public {
        vm.startBroadcast();

        //diceGame = new DiceGame();

        vm.stopBroadcast();
    }
}
