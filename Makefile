include .env

NETWORK_ARGS := --fork-url $(FORK_URL) 
SCRIPT_ARGS := --rpc-url $(ORIGIN_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast 
REACTIVE_ARGS := --rpc-url $(REACTIVE_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast 

build:
	forge build

testing-price:
	forge test --mt test_getLatestPrice $(NETWORK_ARGS) -vvv

testing-data:
	forge test --mt test_getLatestPriceData $(NETWORK_ARGS) -vvv

deploy-feedproxy:
	forge script script/DeployFeedProxyCallback.s.sol $(SCRIPT_ARGS) -vvv

deploy-reactive:
	forge script script/DeployPriceFeedReactive.s.sol $(REACTIVE_ARGS) -vvv

read-feed-price:
	cast call $(FEED_DESTINATION) "getLatestFeedData()(address,uint80,int256,uint256)" --rpc-url $(ORIGIN_RPC_URL)

