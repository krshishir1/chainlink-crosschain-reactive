// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {FeedProxyCallback} from "../src/FeedProxyCallback.sol";

// Testing deployment in Sepolia with private key.

contract DeployFeedProxyCallback is Script {
    address private constant SEPOLIA_PROXY_ADDR =
        0xc9f36411C9897e7F959D99ffca2a0Ba7ee0D7bDA;
    uint256 private constant INITIAL_AMOUNT = 0.001 ether;

    function run() public returns (FeedProxyCallback deployed) {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        deployed = new FeedProxyCallback{value: INITIAL_AMOUNT}(
            SEPOLIA_PROXY_ADDR
        );

        vm.stopBroadcast();
    }
}
