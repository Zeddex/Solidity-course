// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract Blocks is ERC721, ERC721URIStorage, Ownable {
    using Strings for uint256;

    uint256 public constant maxSupply = 100;
    uint256 public cost = 1 ether;
    uint256 private _premint = 10;
    uint256 private _nextTokenId;

    constructor(address initialOwner)
        ERC721("Blocks", "BLK")
        Ownable(initialOwner)
    {
        uint premintAmount = _premint;

        for (uint i = 1; i <= premintAmount; i++) {
            safeMint(msg.sender);
        }
    }

    modifier ensureAvailability() {
        require(availableTokens() > 0, "No more tokens available");
        _;
    }

    modifier mintRequirements() {
        require(tokenCount() + 1 <= maxSupply, "You cannot mint more than maximum supply");
        require( tx.origin == msg.sender, "Cannot mint through a custom contract");
        _;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmejrKMDm4AZjf9v3qZLfuUfRTaVMy3VKW5SvZBuzDdcor/";
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function mint() public payable mintRequirements {
        if (msg.sender != owner()) {  
          require(msg.value >= cost, "Insufficient funds!");
        }
      
        safeMint(msg.sender);
    }

    function mintToAddress(address to) public onlyOwner mintRequirements {      
        safeMint(to);
    }

    function setPrice(uint256 newPrice) public onlyOwner {
        cost = newPrice;
    }
  
    function withdraw() public payable onlyOwner {
        (bool sent, ) = payable(owner()).call{value: address(this).balance}("");
        require(sent, "Transfer failed");
    }

    function availableTokens() public view returns (uint256) {
        return maxSupply - tokenCount();
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
         _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString(), ".json") : "";
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
