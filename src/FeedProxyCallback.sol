// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@reactive/contracts/abstract-base/AbstractCallback.sol";
import {IPriceFeed} from "./interfaces/IPriceFeed.sol";

// destination contract

struct PriceUpdate {
    uint80 roundId;
    int256 answer;
    uint256 startedAt;
    uint256 updatedAt;
    uint80 answeredInRound;
}

contract FeedProxyCallback is AbstractCallback {
    error FeedProxy__InvalidRoundIdReceived();
    error FeedProxy__InvalidAnswerProvided();
    error FeedProxy__InvalidRoundId();
    error FeedProxy__NoDataForRound(uint80 roundId);

    event FeedUpdated(uint80 indexed roundId, int256 answer, uint256 updatedAt);

    struct RoundData {
        int256 answer;
        uint256 startedAt;
        uint256 updatedAt;
        uint80 answeredInRound;
    }

    address private immutable i_sourceFeedAddr;
    uint8 private immutable i_decimals;
    uint256 private immutable i_src_chainid;
    string private i_description;

    uint80 private latestRoundId;
    mapping(uint80 => RoundData) private s_rounds;

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

        s_rounds[data.roundId] = RoundData({
            answer: data.answer,
            startedAt: data.startedAt,
            updatedAt: data.updatedAt,
            answeredInRound: data.answeredInRound
        });

        if (data.roundId > latestRoundId) {
            latestRoundId = data.roundId;
        }

        emit FeedUpdated(data.roundId, data.answer, data.updatedAt);
    }

    // ========================================================
    // ============= CHAINLINK-COMPATIBLE GETTERS =============
    // ========================================================

    function getLatestFeedData()
        public
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        if (latestRoundId == 0) revert FeedProxy__InvalidRoundId();

        RoundData memory rd = s_rounds[latestRoundId];

        return (
            latestRoundId,
            rd.answer,
            rd.startedAt,
            rd.updatedAt,
            rd.answeredInRound
        );
    }

    function getFeedDataByRoundId(
        uint80 roundId
    ) external view returns (uint80, int256, uint256, uint256, uint80) {
        RoundData memory rd = s_rounds[roundId];
        if (rd.updatedAt == 0) revert FeedProxy__NoDataForRound(roundId);

        return (
            roundId,
            rd.answer,
            rd.startedAt,
            rd.updatedAt,
            rd.answeredInRound
        );
    }

    function getDecimals() public view returns (uint8) {
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
