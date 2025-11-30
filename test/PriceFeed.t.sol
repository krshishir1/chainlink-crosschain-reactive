// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import "../src/PriceFeed.sol";
import {IPriceFeed} from "../src/interfaces/IPriceFeed.sol";

// import "./mocks/MockV3Aggregator.sol";

contract PriceFeedConsumerTest is Test {
    // MockV3Aggregator mockFeed;
    PriceFeedConsumer private priceFeed;

    uint8 constant DECIMALS = 8;
    int256 constant INITIAL_PRICE = 2000e8;

    address private constant feedAddress =
        0x694AA1769357215DE4FAC081bf1f309aDC325306;

    function setUp() public {
        // mockFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        priceFeed = new PriceFeedConsumer(feedAddress);
    }

    function test_getLatestPrice() public view {
        int256 price = priceFeed.getLatestPrice();
        console.log(price);
    }

    function test_getLatestPriceData() public view {
        IPriceFeed.PriceData memory data = priceFeed.getLatestPriceData();
        console.log("Round Id:", data.roundId);
        console.log("Answer: ", data.answer);
        console.log("Started At: ", data.startedAt);
        console.log("Updated At: ", data.updatedAt);
        console.log("answeredInRound: ", data.answeredInRound);
    }
}
