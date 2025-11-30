include .env

CHAIN_ID ?= 11155111
PRICE_FEED ?= 0x694AA1769357215DE4FAC081bf1f309aDC325306

NETWORK_ARGS := --fork-url $(FORK_URL) 
ORIGIN_ARGS := --rpc-url $(ORIGIN_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast 
DESTINATION_ARGS := --rpc-url $(DEST_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast 
REACTIVE_ARGS := --broadcast --rpc-url $(REACTIVE_RPC_URL) --private-key $(PRIVATE_KEY) --constructor-args $(CHAIN_ID) $(PRICE_FEED) $(FEED_DESTINATION)

build:
	forge build

build-feedproxy:
	forge create src/FeedProxyCallback.sol:FeedProxyCallback \
		--constructor-args \
		$(CALLBACK_SENDER) \
		$(SOURCE_FEED_ADDR) \
		$(SOURCE_CHAINID) \
		$(DECIMALS) \
		"$(DESCRIPTION)" \
		--private-key $(PRIVATE_KEY)

deploy-reactive:
	forge create src/PriceFeedReactive.sol:PriceFeedReactive $(REACTIVE_ARGS)

get-originFeed:
	forge script script/DeployPriceFeedOrigin.s.sol $(ORIGIN_ARGS) -vvv

deploy-feedProxyCallback:
	forge script script/DeployFeedProxyCallback.s.sol $(DESTINATION_ARGS) -vvv

deploy-all:
	forge script script/DeployPriceFeedOrigin.s.sol $(ORIGIN_ARGS) -vvv
	forge script script/DeployFeedProxyCallback.s.sol $(DESTINATION_ARGS) -vvv
