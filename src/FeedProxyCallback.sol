// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@reactive/contracts/abstract-base/AbstractCallback.sol";
import {IPriceFeed} from "./interfaces/IPriceFeed.sol";

// destination

contract FeedProxyCallback is AbstractCallback {
    error FeedProxy__InvalidRoundIdReceived();
    error FeedProxy__InvalidAnswerProvided();

    event FeedUpdated(
        address indexed sourceFeed,
        uint80 roundId,
        int256 answer,
        uint256 updatedAt
    );

    struct PriceUpdate {
        address sourceFeed;
        uint80 roundId;
        int256 answer;
        uint256 updatedAt;
    }

    address private immutable i_sourceFeedAddr;
    uint8 private immutable i_decimals;
    uint256 private immutable i_src_chainid;
    string private i_description;

    PriceUpdate private latestPriceData;

    constructor(
        address _callback_sender,
        address _source_addr,
        uint256 _source_chainid,
        uint8 _decimals,
        string memory _description
    ) payable AbstractCallback(_callback_sender) {
        i_sourceFeedAddr = _source_addr;
        i_src_chainid = _source_chainid;
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

    function getDecimals() public view returns (uint256) {
        return i_decimals;
    }

    function getDescription() public view returns (string memory) {
        return i_description;
    }

    function getSourceFeedAddress() public view returns (address) {
        return i_sourceFeedAddr;
    }

    function getSourceChainId() public view returns (uint256) {
        return i_src_chainid;
    }
}
