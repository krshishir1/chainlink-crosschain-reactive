// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {PriceFeedReactive} from "../src/PriceFeedReactive.sol";

// Testing deployment in Sepolia with private key.

contract DeployFeedProxyCallback is Script {
    uint256 private constant ORIGIN_CHAIN_ID = 11155111;
    address private constant ORIGIN_FEED_ADDR =
        0x694AA1769357215DE4FAC081bf1f309aDC325306; // ETH/USD setup for sepolia
    address private constant FEED_PROXY_ADDR =
        0xBF9E0Cf24f34FEd15b1dA656110782A2EB061B26;

    uint256 private constant INITIAL_AMOUNT = 0.05 ether;

    function run() public returns (PriceFeedReactive deployed) {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        deployed = new PriceFeedReactive{value: INITIAL_AMOUNT}(
            ORIGIN_CHAIN_ID,
            ORIGIN_FEED_ADDR,
            FEED_PROXY_ADDR
        );

        vm.stopBroadcast();
    }
}
