// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Bridge} from "../src/Bridge.sol";

contract CounterScript is Script {
    Bridge public bridge;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        //Bridge = new Bridge();

        vm.stopBroadcast();
    }
}
