// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {FeedProxyCallback} from "../src/FeedProxyCallback.sol";
import {IPriceFeed} from "../src/interfaces/IPriceFeed.sol";

// contract CrossChainOrchestrator is Script {
//     address private constant SEPOLIA_PROXY_ADDR =
//         0xc9f36411C9897e7F959D99ffca2a0Ba7ee0D7bDA;
//     uint256 private constant INITIAL_AMOUNT = 0.001 ether;

//     function run() external returns (FeedProxyCallback deployed) {
//         //
//         // Read from Sepolia
//         //
//         address sepoliaRpc = vm.envAddress("ORIGIN_RPC_URL");
//         address feedProxy = SEPOLIA_PROXY_ADDR;
//         uint256 forkId = vm.createFork(sepoliaRpc);
//         vm.selectFork(forkId);

//         // read struct from sepolia by performing an eth_call
//         uint8 decimals = IPriceFeed(feedProxy).decimals();

//         console2.log("Fetched from Sepolia:");
//         console2.log("Decimals:   ", decimals);

//         //
//         // 2️⃣ Use the same data on ANOTHER NETWORK
//         //
//         uint256 pk = vm.envUint("PRIVATE_KEY");
//         address destRpc = vm.envAddress("DEST_RPC_URL");

//         vm.startBroadcast(pk);

//         // For example, deploy a contract with these parameters
//         deployed = new FeedProxyCallback{value: INITIAL_AMOUNT}(
//             SEPOLIA_PROXY_ADDR
//         );

//         vm.stopBroadcast();

//         console2.log("Deployed on destination chain:", address(deployed));
//     }
// }
