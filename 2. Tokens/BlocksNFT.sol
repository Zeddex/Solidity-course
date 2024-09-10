// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./ERC721.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";

contract Blocks is ERC721 {
    using Strings for uint256;

    address public contractOwner;
    uint256 public totalSupply = 100;
    uint256 public tokenPrice = 1 ether;
    uint256 public totalMinted;

    uint256 private _tokenIdCounter;
    uint256 private _premint = 10;
    uint256 private _nextTokenId;
    string private _baseUri = "ipfs://QmejrKMDm4AZjf9v3qZLfuUfRTaVMy3VKW5SvZBuzDdcor/";

    constructor() ERC721("Blocks", "BLK") {
        contractOwner = msg.sender;

        uint premintAmount = _premint;
        for (uint i = 1; i <= premintAmount; i++) {
            mint(msg.sender);
        }
    }

    modifier onlyContractOwner {
        require(contractOwner == msg.sender, "Not contract owner");
        _;
    }

    modifier mintAvailable {
        require(totalMinted < totalSupply, "Maximum supply minted");
        _;
    }

    modifier tokenExists(uint256 tokenId) {
        require(_ownerOf[tokenId] != address(0), "Token does not exist");
        _;
    }

    function tokenURI(uint256 tokenId) public view tokenExists(tokenId) tokenExists(tokenId) override returns (string memory) {
        string memory currentBaseURI = _baseUri;

        return string(abi.encodePacked(currentBaseURI, tokenId.toString(), ".json"));
    }

    function mint(address receiver) public onlyContractOwner mintAvailable {
        _safeMint(receiver, ++_tokenIdCounter);
        totalMinted++;
    }

    function mint() external payable mintAvailable {
        if (msg.sender != contractOwner) {  
          require(msg.value >= tokenPrice, "Insufficient funds");
        }
      
        _safeMint(msg.sender, ++_tokenIdCounter);
        totalMinted++;
    }

    function setPrice(uint256 newPrice) external onlyContractOwner {
        tokenPrice = newPrice;
    }
  
    function withdraw() external payable onlyContractOwner {
        (bool success, ) = payable(contractOwner).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
}
