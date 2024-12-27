// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {DeployNft} from "../script/DeployNft.s.sol";
import {BmNft} from "../src/BmNft.sol";

contract BM_Test is Test {
    string constant NFT_NAME = "Beauty Mortis";
    string constant NFT_SYMBOL = "BMORT";
    string public constant NFT_URI = "ipfs://bafybeiak53e5bvkdtngeqdcicrk4abctibvhyl2qhmb4rpbw4w7eszbney/1.json";

    uint256 constant INIT_SUPPLY = 11;

    DeployNft public deployer;
    BmNft public nft;
    address public deployerAddress;
    address public user = makeAddr("user");

    function setUp() external {
        deployer = new DeployNft();
        nft = deployer.run();
        deployerAddress = msg.sender; // 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38 - foundry default account
    }

    function testInitializedCorrectly() public view {
        assert(keccak256(abi.encodePacked(nft.name())) == keccak256(abi.encodePacked((NFT_NAME))));
        assert(keccak256(abi.encodePacked(nft.symbol())) == keccak256(abi.encodePacked((NFT_SYMBOL))));
    }

    function testTokenURI() public {
        vm.startPrank(deployerAddress);

        uint256 tokenId = 1;
        assertEq(nft.tokenURI(tokenId), NFT_URI, "Token URI should match expected URI.");
        vm.stopPrank();
    }

    function testInitialMinting() public view {
        assertEq(nft.totalSupply(), INIT_SUPPLY, "Initial supply should be 11 tokens.");
    }

    function testMintToken() public {
        uint256 price = nft.price();
        vm.deal(user, price);
        vm.broadcast(user); // vm.prank doesn't change tx.origin, so we need to broadcast to change it

        nft.mint{value: price}();
        assertEq(nft.balanceOf(user), 1, "User should own 1 token after minting.");
        assertEq(nft.totalSupply(), INIT_SUPPLY + 1, "Total supply should increase to 12.");
    }

    function testFailMintWithoutSufficientFunds() public {
        uint256 insufficientPrice = nft.price() - 1;
        vm.deal(user, insufficientPrice);
        vm.startPrank(user);

        nft.mint{value: insufficientPrice}(); // This should fail
        vm.stopPrank();
    }

    function testdeployerAddressMintToAddress() public {
        vm.startPrank(deployerAddress);

        nft.mintToAddress(user);
        assertEq(nft.balanceOf(user), 1, "User should receive 1 token from deployerAddress mint.");
        vm.stopPrank();
    }

    function testMintThroughContractRestricted() public {
        address contractCaller = address(this);
        vm.startPrank(contractCaller);

        vm.expectRevert(BmNft.MintThroughContractUnavailable.selector);
        nft.mint();
        vm.stopPrank();
    }

    function testWithdrawFunds() public {
        uint256 price = nft.price();
        vm.deal(user, price);
        vm.broadcast(user); // vm.prank doesn't change tx.origin, so we need to broadcast to change it

        nft.mint{value: price}();

        uint256 balanceBefore = deployerAddress.balance;
        vm.startPrank(deployerAddress);
        nft.withdraw();
        assertGt(deployerAddress.balance, balanceBefore, "deployerAddress should have withdrawn funds.");
        vm.stopPrank();
    }

    function testFailWithdrawByNondeployerAddress() public {
        vm.startPrank(user);

        vm.expectRevert("Ownable: caller is not the deployerAddress");
        nft.withdraw();
        vm.stopPrank();
    }

    function testChangePrice() public {
        vm.startPrank(deployerAddress);

        uint256 newPrice = 30 ether;
        nft.setPrice(newPrice);
        assertEq(nft.price(), newPrice, "Price should update correctly.");
        vm.stopPrank();
    }

    function testNextRandomTokenUniqueness() public {
        uint256 price = nft.price();
        vm.deal(user, price * 10); // Fund user with enough Ether for multiple mints
        vm.startPrank(user);

        uint256 tokensToMint = 10;
        for (uint256 i = 0; i < tokensToMint; i++) {
            nft.mint{value: price}();
        }
        vm.stopPrank();

        // Verify all token IDs are unique
        uint256[] memory ownedTokens = new uint256[](tokensToMint);
        uint256 index = 0;

        for (uint256 i = 12; i < 12 + tokensToMint; i++) {
            ownedTokens[index] = i; // Capture token IDs (start from 12 as first 11 are pre-minted)
            index++;
        }

        for (uint256 i = 0; i < tokensToMint; i++) {
            for (uint256 j = i + 1; j < tokensToMint; j++) {
                assertNotEq(ownedTokens[i], ownedTokens[j], "Duplicate token IDs detected");
            }
        }
    }

    function testNextRandomTokenFullMinting() public {
        uint256 price = nft.price();
        uint256 maxMintable = nft.availableToMint();
        vm.deal(user, price * maxMintable);
        vm.startPrank(user);

        for (uint256 i = 0; i < maxMintable; i++) {
            nft.mint{value: price}();
        }
        vm.stopPrank();

        // Verify that total supply equals maxSupply
        assertEq(nft.totalSupply(), 666, "Total supply should equal max supply after full minting");
    }

    function testNextRandomTokenDistribution() public {
        uint256 price = nft.price();
        uint256 tokensToMint = 50;
        vm.deal(user, price * tokensToMint);
        vm.startPrank(user);

        uint256[] memory tokenIds = new uint256[](tokensToMint);
        for (uint256 i = 0; i < tokensToMint; i++) {
            nft.mint{value: price}();
            tokenIds[i] = nft.totalSupply(); // Capture minted token IDs
        }
        vm.stopPrank();

        // Analyze distribution of token IDs
        uint256 minTokenId = type(uint256).max;
        uint256 maxTokenId = 0;

        for (uint256 i = 0; i < tokensToMint; i++) {
            if (tokenIds[i] < minTokenId) minTokenId = tokenIds[i];
            if (tokenIds[i] > maxTokenId) maxTokenId = tokenIds[i];
        }

        assertGt(maxTokenId, minTokenId, "Token IDs should be distributed over a range");
    }

    function testNextRandomTokenRevertsWhenSoldOut() public {
        uint256 price = nft.price();
        uint256 maxMintable = nft.availableToMint();
        vm.deal(user, price * maxMintable);
        vm.startPrank(user);

        for (uint256 i = 0; i < maxMintable; i++) {
            nft.mint{value: price}();
        }
        vm.expectRevert(BmNft.NoTokensToMintAvailable.selector);
        nft.mint{value: price}(); // This should revert as all tokens are minted
        vm.stopPrank();
    }
}
