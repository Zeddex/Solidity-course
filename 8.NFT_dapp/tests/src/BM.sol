// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

event Minted(address owner, uint256 tokenId);

error InsufficientFunds();
error WithdrawalFailed();
error NoTokensToMintAvailable();
error MintThroughContractUnavailable();

library Counters {
    struct Counter {
        uint256 _value;
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

contract BMortis is ERC721, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _currentSupply;
    Counters.Counter private _tokensMinted;

    mapping(uint256 => uint256) private tokenMatrix;

    uint256 public price = 20 ether;
    uint256 public constant maxSupply = 666;
    string private constant baseURI = "ipfs://bafybeiak53e5bvkdtngeqdcicrk4abctibvhyl2qhmb4rpbw4w7eszbney/";
    uint256 private constant premint = 11;
    uint256 private startRndCount = premint + 1;

    constructor() ERC721("Beauty Mortis", "BMORT") Ownable(msg.sender) {
        // mint first 11 tokens to onwer
        for (uint256 i = 1; i <= premint; ++i) {
            _safeMint(msg.sender, i);

            _tokensMinted.increment();
            currentSupplyIncrement();

            emit Minted(msg.sender, i);
        }
    }

    modifier ensureAvailability() {
        require(availableToMint() > 0, NoTokensToMintAvailable());
        _;
    }

    modifier mintRequirements() {
        require(tokensMinted() + 1 <= maxSupply, NoTokensToMintAvailable());
        require(availableToMint() > 0, NoTokensToMintAvailable());
        require(tx.origin == msg.sender, MintThroughContractUnavailable());
        _;
    }

    function mint() public payable mintRequirements {
        require(msg.value >= price, InsufficientFunds());

        uint256 tokenId = nextRandomToken();

        _safeMint(msg.sender, tokenId);

        currentSupplyIncrement();

        emit Minted(msg.sender, tokenId);
    }

    function mintToAddress(address to) public onlyOwner mintRequirements {
        uint256 tokenId = nextRandomToken();

        _safeMint(to, tokenId);

        currentSupplyIncrement();

        emit Minted(to, tokenId);
    }

    function setPrice(uint256 newPrice) public onlyOwner {
        price = newPrice;
    }

    function withdraw() public payable onlyOwner {
        (bool sent,) = owner().call{value: address(this).balance}("");

        if (!sent) {
            revert WithdrawalFailed();
        }
    }

    function totalSupply() public view returns (uint256) {
        return _currentSupply.current();
    }

    function availableToMint() public view returns (uint256) {
        return maxSupply - tokensMinted();
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        string memory currentBaseURI = _baseURI();

        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), ".json"))
            : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokensMinted() private view returns (uint256) {
        return _tokensMinted.current();
    }

    function currentSupplyIncrement() private {
        _currentSupply.increment();
    }

    function nextRandomToken() private ensureAvailability returns (uint256) {
        uint256 maxIndex = maxSupply - tokensMinted();
        uint256 random = uint256(
            keccak256(abi.encodePacked(msg.sender, block.coinbase, block.prevrandao, block.gaslimit, block.timestamp))
        ) % maxIndex;

        uint256 value = 0;

        if (tokenMatrix[random] == 0) {
            // If this matrix position is empty, set the value to the generated random number.
            value = random;
        } else {
            // Otherwise, use the previously stored number from the matrix.
            value = tokenMatrix[random];
        }

        // If the last available tokenID is still unused...
        if (tokenMatrix[maxIndex - 1] == 0) {
            // ...store that ID in the current matrix position.
            tokenMatrix[random] = maxIndex - 1;
        } else {
            // ...otherwise copy over the stored number to the current matrix position.
            tokenMatrix[random] = tokenMatrix[maxIndex - 1];
        }

        // Increment counts
        _tokensMinted.increment();

        return value + startRndCount;
    }
}
