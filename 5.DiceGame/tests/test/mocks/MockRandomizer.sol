// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IRandomizer {
    function requestRandomWords() external returns (uint256 requestId);
    function getRequestStatus(uint256 _requestId)
        external
        view
        returns (bool fulfilled, uint256[] memory randomWords);
}

contract MockRandomizer is IRandomizer {
    mapping(uint256 => uint256[]) public randomWords;
    mapping(uint256 => bool) private requestExists;
    uint256 public currentRequestId;

    function requestRandomWords() external override returns (uint256) {
        currentRequestId++;
        requestExists[currentRequestId] = false; // Initially, the request is not fulfilled
        return currentRequestId;
    }

    function mockFulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) external {
        randomWords[_requestId] = _randomWords;
        requestExists[_requestId] = true; // Mark as fulfilled
    }

    function getRequestStatus(uint256 _requestId)
        external
        view
        override
        returns (bool fulfilled, uint256[] memory randomWordsOut)
    {
        return (requestExists[_requestId], randomWords[_requestId]);
    }
}
