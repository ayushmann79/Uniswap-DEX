// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ERC20Mock} from "../src/ERC20Mock.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {UniswapV2RouterSimple} from "../src/UniswapV2RouterSimple.sol";

contract DebugSwap is Script {
    function run() external {
        uint256 privateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        address deployer = vm.addr(privateKey);
        
        vm.startBroadcast(privateKey);

        // Use existing deployed contracts (Anvil default addresses)
        ERC20Mock tokenA = ERC20Mock(0x5FbDB2315678afecb367f032d93F642f64180aa3);
        ERC20Mock tokenB = ERC20Mock(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512);
        UniswapV2Factory factory = UniswapV2Factory(0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0);
        UniswapV2RouterSimple router = UniswapV2RouterSimple(0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9);

        console.log("=== DEX SETUP & SWAP TEST ===");
        
        // Step 1: Mint tokens if needed
        console.log("1. Minting tokens...");
        tokenA.mint(deployer, 1_000_000 ether);
        tokenB.mint(deployer, 1_000_000 ether);
        
        console.log("Initial balances:");
        console.log("TokenA:", tokenA.balanceOf(deployer) / 1e18);
        console.log("TokenB:", tokenB.balanceOf(deployer) / 1e18);

        // Step 2: Create pair (if not exists)
        console.log("2. Creating pair...");
        address pair = factory.createPair(address(tokenA), address(tokenB));
        console.log("Pair created at:", pair);

        // Step 3: Approve router
        console.log("3. Approving router...");
        tokenA.approve(address(router), type(uint256).max);
        tokenB.approve(address(router), type(uint256).max);

        // Step 4: Add liquidity
        console.log("4. Adding liquidity...");
        uint256 liquidity = router.addLiquidity(
            address(tokenA),
            address(tokenB),
            10_000 ether, // amountADesired
            20_000 ether, // amountBDesired
            1,            // amountAMin
            1,            // amountBMin
            deployer      // to
        );
        console.log("Liquidity received:", liquidity / 1e18);

        // Step 5: Check pool state
        console.log("5. Pool state:");
        console.log("TokenA in pool:", tokenA.balanceOf(pair) / 1e18);
        console.log("TokenB in pool:", tokenB.balanceOf(pair) / 1e18);

        // Step 6: Perform swap
        console.log("6. Performing swap...");
        uint256 tokenBBefore = tokenB.balanceOf(deployer);
        uint256 swapAmount = 100 ether;
        
        console.log("Swapping", swapAmount / 1e18, "TokenA for TokenB");
        
        uint256 amountOut = router.swapExactTokensForTokens(
            address(tokenA),
            address(tokenB),
            swapAmount,
            0,        // amountOutMin
            deployer  // to
        );
        
        uint256 tokenBAfter = tokenB.balanceOf(deployer);
        console.log("TokenB received:", (tokenBAfter - tokenBBefore) / 1e18);
        console.log("Actual amountOut:", amountOut / 1e18);

        // Final state
        console.log("=== FINAL STATE ===");
        console.log("TokenA balance:", tokenA.balanceOf(deployer) / 1e18);
        console.log("TokenB balance:", tokenB.balanceOf(deployer) / 1e18);
        console.log("LP tokens:", liquidity / 1e18);

        vm.stopBroadcast();
    }
}