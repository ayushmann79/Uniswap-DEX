// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/UniswapV2Factory.sol";

contract DeployFactory is Script {
    function run() external {
        vm.startBroadcast();
        UniswapV2Factory factory = new UniswapV2Factory(); // ✅ FIXED
        vm.stopBroadcast();
        console.log("Factory deployed at:", address(factory));
    }
}
