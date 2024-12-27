// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {Script} from "forge-std/script.sol";
import {BmNft} from "../src/BmNft.sol";

contract DeployNft is Script {
    function run() external returns (BmNft) {
        vm.startBroadcast();
        BmNft nft = new BmNft();
        vm.stopBroadcast();
        return nft;
    }
}
