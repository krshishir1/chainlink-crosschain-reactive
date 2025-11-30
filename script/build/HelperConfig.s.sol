// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";

abstract contract CodeConstants {
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 public constant ARB_SEPOLIA_CHAIN_ID = 421614;
    uint256 public constant ARB_MAINNET_CHAIN_ID = 42161;
}

contract HelperConfig is CodeConstants, Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        address priceFeedAddress;
        address proxyAddress;
        uint256 chainid;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaConfig(
            ETH_SEPOLIA_CHAIN_ID
        );
        networkConfigs[ETH_MAINNET_CHAIN_ID] = getMainnetConfig(
            ETH_MAINNET_CHAIN_ID
        );
        networkConfigs[ARB_SEPOLIA_CHAIN_ID] = getArbitrumSepoliaConfig(
            ARB_SEPOLIA_CHAIN_ID
        );
        networkConfigs[ARB_MAINNET_CHAIN_ID] = getArbitrumMainnetConfig(
            ARB_MAINNET_CHAIN_ID
        );
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function setConfig(
        uint256 chainId,
        NetworkConfig memory networkConfig
    ) public {
        networkConfigs[chainId] = networkConfig;
    }

    function getConfigByChainId(
        uint256 chainId
    ) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].priceFeedAddress != address(0)) {
            return networkConfigs[chainId];
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getMainnetConfig(
        uint256 chain_id
    ) internal pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeedAddress: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419,
                proxyAddress: 0x1D5267C1bb7D8bA68964dDF3990601BDB7902D76,
                chainid: chain_id
            });
    }

    function getSepoliaConfig(
        uint256 chain_id
    ) internal pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
                proxyAddress: 0xc9f36411C9897e7F959D99ffca2a0Ba7ee0D7bDA,
                chainid: chain_id
            });
    }

    function getArbitrumMainnetConfig(
        uint256 chain_id
    ) internal pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeedAddress: 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612,
                proxyAddress: 0x4730c58FDA9d78f60c987039aEaB7d261aAd942E,
                chainid: chain_id
            });
    }

    function getArbitrumSepoliaConfig(
        uint256 chain_id
    ) internal pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
                proxyAddress: address(0),
                chainid: chain_id
            });
    }
}
