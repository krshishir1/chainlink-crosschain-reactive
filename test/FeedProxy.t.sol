// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import {MockV3Aggregator} from "./mocks/MockV3Aggregator.sol";
import {FeedProxyCallback} from "../src/FeedProxyCallback.sol";

contract FeedProxyTest is Test {
    /* 
        Run `make deploy-testing`
        Get MOCK_FEED_ADDR from terminal logs or srcipt/artifacts/feed.json => feedProxy
        Get FEED_CALLBACK_ADDR from terminal logs
    */

    address public constant MOCK_FEED_ADDR =
        0xe56E4A4176B498793D13AD84d910d604b7012Ab8;
    address private constant FEED_CALLBACK_ADDR =
        0x02B40609D80F8Cb2488a38B50b4cB35d3f73b965;

    MockV3Aggregator mock;

    event AnswerUpdated(
        int256 indexed current,
        uint256 indexed roundId,
        uint256 updatedAt
    );

    event NewRound(
        uint256 indexed roundId,
        address indexed startedBy,
        uint256 startedAt
    );

    function setUp() public {
        console.log(block.chainid);
        string memory RPC_URL = vm.envString("ORIGIN_RPC_URL");

        vm.createSelectFork(RPC_URL);
        mock = MockV3Aggregator(MOCK_FEED_ADDR);
    }

    function testUpdateAnswer_EmitsEvent() public {
        int256 answer = 2050e8;
        uint80 oldRound = mock.latestRound();

        vm.warp(1700000000);

        vm.expectEmit(true, true, true, true);
        emit NewRound(oldRound + 1, address(this), 1700000000);

        vm.expectEmit(true, true, true, true);
        emit AnswerUpdated(answer, oldRound + 1, 1700000000);

        // Call the function on the real deployed mock
        mock.updateAnswer(answer);

        // Validate state
        assertEq(mock.latestRound(), oldRound + 1);
        assertEq(mock.latestAnswer(), answer);
        assertEq(mock.latestTimestamp(), 1700000000);
        assertEq(mock.answers(oldRound + 1), answer);
        assertEq(mock.timestamps(oldRound + 1), 1700000000);
    }
}
