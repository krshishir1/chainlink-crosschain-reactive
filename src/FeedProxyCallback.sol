// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@reactive/contracts/abstract-base/AbstractCallback.sol";

struct PriceUpdate {
    address sourceFeed;
    uint80 roundId;
    int256 answer;
    uint256 updatedAt;
}

// deploying this one in Sepolia network

contract FeedProxyCallback is AbstractCallback {
    error FeedProxy__InvalidRoundIdReceived();
    error FeedProxy__InvalidAnswerProvided();

    event FeedUpdated(
        address indexed sourceFeed,
        uint80 roundId,
        int256 answer,
        uint256 updatedAt
    );

    PriceUpdate private latestPriceData;

    constructor(
        address _callback_sender
    ) payable AbstractCallback(_callback_sender) {}

    function callback(
        address /* sender */,
        PriceUpdate calldata data
    ) external authorizedSenderOnly {
        if (data.roundId == 0) {
            revert FeedProxy__InvalidRoundIdReceived();
        }

        if (data.answer <= 0) {
            revert FeedProxy__InvalidAnswerProvided();
        }

        latestPriceData = data;
        emit FeedUpdated(
            data.sourceFeed,
            data.roundId,
            data.answer,
            data.updatedAt
        );
    }

    function getLatestFeedData() public view returns (PriceUpdate memory) {
        return latestPriceData;
    }
}
