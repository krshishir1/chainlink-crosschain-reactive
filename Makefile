include .env

CHAIN_ID ?= 11155111
PRICE_FEED ?= 0x694AA1769357215DE4FAC081bf1f309aDC325306
REACTIVE_ADDR ?= 0x0000000000000000000000000000000000000000
MOCK_ADDR ?= 0x0000000000000000000000000000000000000000
DECIMALS ?= 8
INITIAL_PRICE ?= 200000000000
ANSWER ?= 205000000000

NETWORK_ARGS := --fork-url $(ORIGIN_RPC_URL) 
ORIGIN_ARGS := --rpc-url $(ORIGIN_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast 
DESTINATION_ARGS := --rpc-url $(DEST_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast 
REACTIVE_ARGS := --broadcast --rpc-url $(REACTIVE_RPC_URL) --private-key $(PRIVATE_KEY) --value 0.01ether --constructor-args $(CHAIN_ID) $(PRICE_FEED) $(FEED_DESTINATION)
MOCK_ARGS := --broadcast --rpc-url $(ORIGIN_RPC_URL) --private-key $(PRIVATE_KEY) --constructor-args $(DECIMALS) $(INITIAL_PRICE)
TESTING_ARGS := --rpc-url $(ORIGIN_RPC_URL) --private-key $(PRIVATE_KEY)

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

deploy-testing:
	forge script script/DeployMockPriceFeed.s.sol $(ORIGIN_ARGS) -vvv
	forge script script/DeployFeedProxyCallback.s.sol $(DESTINATION_ARGS) -vvv


read-latestFeed:
	cast call $(FEED_DESTINATION) "getLatestFeedData()(address,uint80,int256,uint256)" --rpc-url $(DEST_RPC_URL)

read-decimals:
	cast call $(FEED_DESTINATION) "getDecimals()(uint8)" --rpc-url $(DEST_RPC_URL)

read-description:
	cast call $(FEED_DESTINATION) "getDescription()(string)" --rpc-url $(DEST_RPC_URL)

read-originFeed:
	cast call $(FEED_DESTINATION) "getSourceFeedAddress()(address)" --rpc-url $(DEST_RPC_URL)
	
pause-reactive:
	cast send $(REACTIVE_ADDR) "pause()" --rpc-url $(REACTIVE_RPC_URL) --private-key $(PRIVATE_KEY)

resume-reactive: 
	cast send $(REACTIVE_ADDR) "resume()" --rpc-url $(REACTIVE_RPC_URL) --private-key $(PRIVATE_KEY)

send-mockUpdate:
	cast send $(MOCK_ADDR) "updateAnswer(int256)" $(ANSWER) $(TESTING_ARGS)

testing-mockEvent:
	forge test --mt testUpdateAnswer_EmitsEvent $(NETWORK_ARGS) -vvv

