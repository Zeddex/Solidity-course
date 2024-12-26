// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BMortis} from "../src/BM.sol";
import {Test, console} from "forge-std/Test.sol";

contract BM_Test is Test {
    BMortis public bmortis;

    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() external {
        vm.startPrank(owner);
        bmortis = new BMortis();
        vm.stopPrank();
    }

    function testInitialMinting() public view {
        assertEq(bmortis.totalSupply(), 11, "Initial supply should be 11 tokens.");
    }

    function testMintToken() public {
        uint256 price = bmortis.price();
        vm.deal(alice, price);
        vm.startPrank(alice);

        bmortis.mint{value: price}();
        assertEq(bmortis.balanceOf(alice), 1, "User should own 1 token after minting.");
        assertEq(bmortis.totalSupply(), 12, "Total supply should increase to 12.");
        vm.stopPrank();
    }

    function testFailMintWithoutSufficientFunds() public {
        uint256 insufficientPrice = bmortis.price() - 1;
        vm.deal(alice, insufficientPrice);
        vm.startPrank(alice);

        bmortis.mint{value: insufficientPrice}(); // This should fail
        vm.stopPrank();
    }

    function testOwnerMintToAddress() public {
        vm.startPrank(owner);

        bmortis.mintToAddress(alice);
        assertEq(bmortis.balanceOf(alice), 1, "User should receive 1 token from owner mint.");
        vm.stopPrank();
    }

    function testFailMintThroughContract() public {
        address contractCaller = address(this);
        vm.startPrank(contractCaller);

        vm.expectRevert(BMortis.MintThroughContractUnavailable.selector);
        bmortis.mint();
        vm.stopPrank();
    }

    function testWithdrawFunds() public {
        uint256 price = bmortis.price();
        vm.deal(alice, price);
        vm.startPrank(alice);

        bmortis.mint{value: price}();
        vm.stopPrank();

        uint256 balanceBefore = owner.balance;
        vm.startPrank(owner);
        bmortis.withdraw();
        assertGt(owner.balance, balanceBefore, "Owner should have withdrawn funds.");
        vm.stopPrank();
    }

    function testFailWithdrawByNonOwner() public {
        vm.startPrank(alice);

        vm.expectRevert("Ownable: caller is not the owner");
        bmortis.withdraw();
        vm.stopPrank();
    }

    function testChangePrice() public {
        vm.startPrank(owner);

        uint256 newPrice = 30 ether;
        bmortis.setPrice(newPrice);
        assertEq(bmortis.price(), newPrice, "Price should update correctly.");
        vm.stopPrank();
    }

    function testTokenURI() public {
        vm.startPrank(owner);

        uint256 tokenId = 1;
        string memory expectedURI = "ipfs://bafybeiak53e5bvkdtngeqdcicrk4abctibvhyl2qhmb4rpbw4w7eszbney/1.json";
        assertEq(bmortis.tokenURI(tokenId), expectedURI, "Token URI should match expected URI.");
        vm.stopPrank();
    }
}
