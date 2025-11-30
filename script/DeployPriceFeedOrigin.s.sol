// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {IPriceFeed} from "../src/interfaces/IPriceFeed.sol";

contract DeployPriceFeedOrigin is Script {
    struct FeedInfo {
        uint8 decimals;
        string description;
    }

    address private constant ORIGIN_FEED_ADDR =
        0x694AA1769357215DE4FAC081bf1f309aDC325306;

    function run() external returns (FeedInfo memory data) {
        IPriceFeed feed = IPriceFeed(ORIGIN_FEED_ADDR);

        uint8 decimals = feed.decimals();
        string memory description = feed.description();

        string memory path = "./script/artifacts/feed.json";

        string memory json;
        json = vm.serializeAddress("feed", "feedProxy", ORIGIN_FEED_ADDR);
        json = vm.serializeUint("feed", "decimals", decimals);
        json = vm.serializeString("feed", "description", description);

        vm.writeJson(json, path);
        console.log("Wrote feed info to:", path);

        return FeedInfo({decimals: decimals, description: description});
    }
}
