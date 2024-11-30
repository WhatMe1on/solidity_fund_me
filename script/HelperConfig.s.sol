// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/tests/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    uint8 DECIMAL = 8;
    int256 INITIAL_ETH_USD_PRICE = 2000e8;
    uint256 SEPOLIA_BLOCK_CHAIN_ID = 11155111;
    uint256 MAIN_NET_ETH_BLOCK_CHAIN_ID = 1;

    struct NetworkConfig {
        address USDPriceAddress;
    }

    constructor() {
        if (block.chainid == SEPOLIA_BLOCK_CHAIN_ID) {
            activeNetworkConfig = getSepoliaNetConfig();
        } else if (block.chainid == MAIN_NET_ETH_BLOCK_CHAIN_ID) {
            activeNetworkConfig = getMainNetETHNetConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilNetConfig();
        }
    }

    function getSepoliaNetConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                USDPriceAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
    }

    function getMainNetETHNetConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        return
            NetworkConfig({
                USDPriceAddress: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
            });
    }

    function getOrCreateAnvilNetConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.USDPriceAddress != address(0)) {
            return activeNetworkConfig;
        }

        // 1. Deploy the mocks
        // 2. Return mock address

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMAL,
            INITIAL_ETH_USD_PRICE
        );
        vm.stopBroadcast();

        return NetworkConfig({USDPriceAddress: address(mockV3Aggregator)});
    }
}
