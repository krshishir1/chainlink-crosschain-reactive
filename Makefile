include .env

NETWORK_ARGS := --fork-url $(FORK_URL) 
ORIGIN_ARGS := --rpc-url $(ORIGIN_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast 
DESTINATION_ARGS := --rpc-url $(DEST_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast 
REACTIVE_ARGS := --rpc-url $(REACTIVE_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast 

build:
	forge build

get-originFeed:
	forge script script/DeployPriceFeedOrigin.s.sol $(ORIGIN_ARGS) -vvv

deploy-feedProxyCallback:
	forge script script/DeployFeedProxyCallback.s.sol $(DESTINATION_ARGS) -vvv

deploy-all:
	forge script script/DeployPriceFeedOrigin.s.sol $(ORIGIN_ARGS) -vvv
	forge script script/DeployFeedProxyCallback.s.sol $(DESTINATION_ARGS) -vvv

