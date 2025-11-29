include .env

NETWORK_ARGS := --fork-url $(FORK_URL) 

build:
	forge build

testing-price:
	forge test --mt test_getLatestPrice $(NETWORK_ARGS) -vvv

