// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@reactive/contracts/abstract-base/AbstractCallback.sol";
import {IPriceFeed} from "./interfaces/IPriceFeed.sol";

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

    address private immutable i_sourceFeedAddr;
    uint8 private immutable i_decimals;
    string private i_description;

    PriceUpdate private latestPriceData;

    constructor(
        address _callback_sender,
        address _source_addr,
        uint8 _decimals,
        string memory _description
    ) payable AbstractCallback(_callback_sender) {
        i_sourceFeedAddr = _source_addr;
        i_decimals = _decimals;
        i_description = _description;
    }

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
