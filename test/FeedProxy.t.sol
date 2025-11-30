// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {FeedProxyCallback} from "../src/FeedProxyCallback.sol";

contract FeedProxy {

    FeedProxyCallback public feed = FeedProxyCallback()

    function test_getLatestPrice() public view {
        int256 price = priceFeed.getLatestPrice();
        console.log(price);
    }
}