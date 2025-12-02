// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract DeployMockPriceFeed is Script {
    // struct FeedInfo {
    //     uint8 decimals;
    //     string description;
    // }

    function run() external returns (MockV3Aggregator mockFeed) {
        uint8 decimals = 8;
        string memory description = "MOCK FEED";
        int256 initialPrice = 200000000000;

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        mockFeed = new MockV3Aggregator(decimals, initialPrice);
        vm.stopBroadcast();
        /* saving origin build setup in artifacts/feed.json */

        string memory path = "./script/artifacts/feed.json";

        string memory json;
        json = vm.serializeAddress("feed", "feedProxy", address(mockFeed));
        json = vm.serializeUint("feed", "decimals", decimals);
        json = vm.serializeString("feed", "description", description);
        json = vm.serializeUint("feed", "chainid", block.chainid);

        vm.writeJson(json, path);
        console.log("Wrote feed info to:", path);
    }
}
