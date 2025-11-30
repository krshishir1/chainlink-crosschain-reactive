// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {FeedProxyCallback} from "../src/FeedProxyCallback.sol";
import {HelperConfig} from "./build/HelperConfig.s.sol";

// Testing deployment in Sepolia with private key.

contract DeployFeedProxyCallback is Script {
    uint256 private constant INITIAL_AMOUNT = 0.001 ether;

    function run() public returns (FeedProxyCallback deployed) {
        string memory path = "./script/artifacts/feed.json";
        string memory json = vm.readFile(path);

        uint8 decimals = uint8(vm.parseJsonUint(json, ".decimals"));
        string memory description = vm.parseJsonString(json, ".description");
        address feedAddress = vm.parseJsonAddress(json, ".feedProxy");
        uint256 chainid = uint256(vm.parseJsonUint(json, ".chainid"));

        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        console.log("Proxy Address: ", config.proxyAddress);

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        deployed = new FeedProxyCallback{value: INITIAL_AMOUNT}(
            config.proxyAddress,
            feedAddress,
            chainid,
            decimals,
            description
        );

        vm.stopBroadcast();
    }
}
