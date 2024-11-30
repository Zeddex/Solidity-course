// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {CustomShop} from "../src/CustomShop.sol";

contract ShopScript is Script {
    CustomShop public shop;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        shop = new CustomShop();

        vm.stopBroadcast();
    }
}
