// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {PriceFeedConsumer} from "../src/PriceFeed.sol";

contract CounterScript is Script {
    address private constant feedAddress =
        0x694AA1769357215DE4FAC081bf1f309aDC325306;
    PriceFeedConsumer public priceFeed;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        priceFeed = new PriceFeedConsumer(feedAddress);

        vm.stopBroadcast();
    }
}
