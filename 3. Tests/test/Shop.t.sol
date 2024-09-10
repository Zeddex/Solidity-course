// SPDX-License-Identifier: UNLICENSED 

pragma solidity ^0.8.26;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {CustomShop} from "../src/CustomShop.sol";
import {IERC20} from "../src/IERC20.sol";

contract ShopTest is Test {
    CustomShop public shop;
    IERC20 public erc20;

    event Bought(address indexed buyer, uint256 amount);

    receive() external payable {}

    function setUp() public {
        shop = new CustomShop();
        erc20 = IERC20(shop.token());

        // console.log("Shop address: ", address(shop));
        // console.log("Test address: ", address(this));
        // console.log("Token address: ", address(shop.token()));
    }

    function test_ShopOwnerAddress() public view {
        assertEq(shop.owner(), address(this));
    }

    function test_ShopAddressValid() public view {
        assertEq(address(shop) != address(0), true);
    }

    function test_Receive() public {
        assertEq(address(shop).balance, 0);

        (bool success, ) = address(shop).call{value: 100}("");
        assertEq(success, true);
        assertEq(address(shop).balance, 100);
    }

    function test_SellTokens() public {      
        // send 100 wei, get 100 tokens and sell them
        (bool success, ) = address(shop).call{value: 666}("");
        assertEq(success, true);

        uint256 tokensAmount = 666;

        assertEq(shop.tokenBalance(address(this)), tokensAmount);

        erc20.approve(address(shop), tokensAmount);
        shop.sell(tokensAmount);
        assertEq(shop.tokenBalance(address(this)), 0);
    }

    function test_BuyTokens() public {
        // send 100 wei, get 100 tokens
        (bool success, ) = address(shop).call{value: 100}("");
        assertEq(success, true);
        assertEq(shop.tokenBalance(address(this)), 100);
    }

    function test_ExpectEmit() public {
        vm.expectEmit(true, false, false, true);
        emit Bought(address(this), 100);

        (bool success, ) = address(shop).call{value: 100}("");
        assertEq(success, true);
    }

    function test_SellWrongAmount() public {
        // trying to sell 100 tokens having 0
        vm.expectRevert("Incorrect amount!");
        shop.sell(100);
    }

    function testFail_WithdrawalAsNotOwner() public {
        vm.prank(address(0));
        shop.withdrawAll();
    }
}