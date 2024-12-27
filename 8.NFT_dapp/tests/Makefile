-include .env

.PHONY: test deploy anvil

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

build:; forge build

test :; forge test 

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 10

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

deploy:
	@forge script script/DeployNft.s.sol:DeployNft $(NETWORK_ARGS)
