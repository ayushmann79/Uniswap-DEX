// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ERC20Mock} from "../src/ERC20Mock.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {UniswapV2RouterSimple} from "../src/UniswapV2RouterSimple.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy mock tokens
        ERC20Mock tokenA = new ERC20Mock("Token A", "TKA");
        ERC20Mock tokenB = new ERC20Mock("Token B", "TKB");

        // Deploy Factory
        UniswapV2Factory factory = new UniswapV2Factory(msg.sender);

        // Deploy Router
        UniswapV2RouterSimple router = new UniswapV2RouterSimple(address(factory));

        console.log("Deployed contracts:");
        console.log("TokenA:", address(tokenA));
        console.log("TokenB:", address(tokenB));
        console.log("Factory:", address(factory));
        console.log("Router:", address(router));

        vm.stopBroadcast();
    }
}