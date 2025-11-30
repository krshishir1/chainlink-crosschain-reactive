# Cross-chain Oracle Price Feed

## Overview

Chainlink Price Feeds are critical infrastructure for DeFi, perpetual exchanges, lending protocols, derivatives, and risk-managed smart contracts. However, not all chains have native Chainlink deployments.

**Note:** This project is using `ETH/USD` as an example for cross-chain testing and deployment. The project can be further expanded to include more data feeds supported by Chainlink.

This project solves that by:

- Reading canonical feeds from an origin network (e.g., Ethereum, Sepolia, Arbitrum)
- Tracking `AnswerUpdated(int256,uint256,uint256)` in a particular chain in Reactive Contract
- Updating a destination-side FeedProxy contract, by managing logs and sending callbacks from Reactive Contract
- Exposing `getLatestFeedData()` similar to real Chainlink aggregator `getLatestRoundData()` in the `src/FeedProxyCallback.sol` contract

## Contracts

**Reactive Contract**: `src/PriceFeedReactive.sol` subscribes to `AnswerUpdated(int256,uint256,uint256)` events via `ANSWER_UPDATED_TOPIC0` on any particular chain. When the AnswerUpdated event is received, it updates the `lastRoundId` to the RC constract and returns the callback the FeedProxy destination contract `src/FeedProxyCallback.sol`. The callback event includes:
`sourceFeed(address), roundId(uint80), answer(int256), updatedAt(uint256)`.

**PriceFeed ProxyCallback Contract**: `src/FeedProxyCallback.sol` manages the receival of the callback from the Reactive contract. It is deployed in a particular chain where Chainlink pricefeed is not available. `src/FeedProxyCallback.sol` ensures the Chainlink-compatible pricefeed data to this chain. It includes the following functions: `getLatestFeedData()`, `getDecimals()`, and `getDescription()`

**HelperConfig Contract**: `script/build/HelperConfig.s.sol` helps to identify the current chainid and returns the compatible `NetworgConfig(priceFeedAddress, destProxyAddress, chainid)` for that chain. It helps for quick deployment setup.

**DeployPriceFeedOrigin.s.sol**: This contract gets the original Chainlink price feed address, and stores data like `decimals`, `description` and `feed_address` for the `FeedProxyCallback.sol` contract deployment.

**DeployFeedProxyCallback.s.sol**: Deploys the `FeedProxyCallback.sol` on a particular chain.

## Contract CI/CD Deployments

This project supports deployments for origin and callback address.
