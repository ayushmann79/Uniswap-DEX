// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC20Mock} from "../src/ERC20Mock.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {UniswapV2RouterSimple} from "../src/UniswapV2RouterSimple.sol";

contract DeployAndTest is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        vm.startBroadcast(deployerPrivateKey);

        console.log("Deployer:", deployer);
        
        // Deploy tokens
        ERC20Mock tokenA = new ERC20Mock("Token A", "TKA");
        ERC20Mock tokenB = new ERC20Mock("Token B", "TKB");
        
        console.log("TokenA deployed at:", address(tokenA));
        console.log("TokenB deployed at:", address(tokenB));

        // Deploy Factory
        UniswapV2Factory factory = new UniswapV2Factory(deployer);
        console.log("Factory deployed at:", address(factory));

        // Deploy Router
        UniswapV2RouterSimple router = new UniswapV2RouterSimple(address(factory));
        console.log("Router deployed at:", address(router));

        // Create pair
        address pair = factory.createPair(address(tokenA), address(tokenB));
        console.log("Pair created at:", pair);

        // Mint tokens to deployer
        tokenA.mint(deployer, 1000000e18);
        tokenB.mint(deployer, 1000000e18);
        console.log("Minted tokens to deployer");

        // Approve router
        tokenA.approve(address(router), type(uint256).max);
        tokenB.approve(address(router), type(uint256).max);
        console.log("Approved router to spend tokens");

        // Add initial liquidity
        uint256 liquidity = router.addLiquidity(
            address(tokenA),
            address(tokenB),
            100000e18,  // 100,000 Token A
            200000e18,  // 200,000 Token B
            1,
            1,
            deployer
        );
        console.log("Added liquidity, received LP tokens:", liquidity);

        vm.stopBroadcast();

        console.log("=== DEPLOYMENT COMPLETE ===");
        console.log("TokenA:", address(tokenA));
        console.log("TokenB:", address(tokenB));
        console.log("Factory:", address(factory));
        console.log("Router:", address(router));
        console.log("Pair:", pair);
    }
}