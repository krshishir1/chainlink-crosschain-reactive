// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {IPriceFeed} from "../src/interfaces/IPriceFeed.sol";
import {HelperConfig} from "./build/HelperConfig.s.sol";

contract DeployPriceFeedOrigin is Script {
    struct FeedInfo {
        uint8 decimals;
        string description;
    }

    function run() external returns (FeedInfo memory data) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        IPriceFeed feed = IPriceFeed(config.priceFeedAddress);

        uint8 decimals = feed.decimals();
        string memory description = feed.description();

        /* saving origin build setup in artifacts/feed.json */

        string memory path = "./script/artifacts/feed.json";

        string memory json;
        json = vm.serializeAddress(
            "feed",
            "feedProxy",
            config.priceFeedAddress
        );
        json = vm.serializeUint("feed", "decimals", decimals);
        json = vm.serializeString("feed", "description", description);
        json = vm.serializeUint("feed", "chainid", config.chainid);

        vm.writeJson(json, path);
        console.log("Wrote feed info to:", path);

        return FeedInfo({decimals: decimals, description: description});
    }
}
