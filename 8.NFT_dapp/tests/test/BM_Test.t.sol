// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BMortis} from "../src/BM.sol";
import {Test, console} from "forge-std/Test.sol";

contract BM_Test is Test {
    BMortis public bm;

    function setUp() external {
        bm = new BMortis();
    }

    function test_() public {}
}
