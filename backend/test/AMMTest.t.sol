// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ERC20Mock} from "../src/ERC20Mock.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {UniswapV2RouterSimple} from "../src/UniswapV2RouterSimple.sol";
import {UniswapV2PairMinimal} from "../src/UniswapV2PairMinimal.sol";

contract AMMTest is Test {
    ERC20Mock tokenA;
    ERC20Mock tokenB;
    UniswapV2Factory factory;
    UniswapV2RouterSimple router;
    address user = address(0x123);

    function setUp() public {
        tokenA = new ERC20Mock("Token A", "TKA");
        tokenB = new ERC20Mock("Token B", "TKB");
        factory = new UniswapV2Factory(address(this));
        router = new UniswapV2RouterSimple(address(factory));

        // Create pair
        factory.createPair(address(tokenA), address(tokenB));

        // Mint substantial tokens for testing
        tokenA.mint(address(this), 100000e18);
        tokenB.mint(address(this), 100000e18);
        tokenA.mint(user, 100000e18);
        tokenB.mint(user, 100000e18);

        // Approve router to spend tokens from this contract
        tokenA.approve(address(router), type(uint256).max);
        tokenB.approve(address(router), type(uint256).max);
        
        // Approve router to spend tokens from user
        vm.prank(user);
        tokenA.approve(address(router), type(uint256).max);
        vm.prank(user);
        tokenB.approve(address(router), type(uint256).max);
    }

    function testAddLiquidity() public {
        uint256 liquidity = router.addLiquidity(
            address(tokenA), 
            address(tokenB), 
            1000e18, 
            2000e18, 
            1, 
            1, 
            address(this)
        );
        assertTrue(liquidity > 0, "Liquidity should be greater than 0");
        
        // Check that LP tokens were minted
        address pair = factory.getPair(address(tokenA), address(tokenB));
        uint256 lpBalance = UniswapV2PairMinimal(pair).balanceOf(address(this));
        assertEq(lpBalance, liquidity, "Should have received LP tokens");
    }

    function testAddLiquidityUser() public {
        vm.prank(user);
        uint256 liquidity = router.addLiquidity(
            address(tokenA), 
            address(tokenB), 
            1000e18, 
            2000e18, 
            1, 
            1, 
            user
        );
        assertTrue(liquidity > 0, "Liquidity should be greater than 0");
        
        // Verify user received LP tokens
        address pair = factory.getPair(address(tokenA), address(tokenB));
        uint256 userBalance = UniswapV2PairMinimal(pair).balanceOf(user);
        assertEq(userBalance, liquidity, "User should have LP tokens");
    }

    function testPairCreation() public view {
        address pair = factory.getPair(address(tokenA), address(tokenB));
        assertTrue(pair != address(0), "Pair should be created");
        
        UniswapV2PairMinimal pairContract = UniswapV2PairMinimal(pair);
        address token0 = pairContract.token0();
        address token1 = pairContract.token1();
        
        // Factory sorts tokens, so we need to check which is which
        assertTrue(
            (token0 == address(tokenA) && token1 == address(tokenB)) ||
            (token0 == address(tokenB) && token1 == address(tokenA)),
            "Pair should contain both tokens"
        );
    }

    function testSwap() public {
        // Add liquidity first with proper amounts
        router.addLiquidity(
            address(tokenA), 
            address(tokenB), 
            10000e18,  // 10000 tokenA
            20000e18,  // 20000 tokenB  
            1, 
            1, 
            address(this)
        );

        // Check balances before swap
        uint256 tokenBBalanceBefore = tokenB.balanceOf(address(this));

        // Perform a very small swap that won't break the constant product
        uint256 out = router.swapExactTokensForTokens(
            address(tokenA), 
            address(tokenB), 
            100e18,     // Swap 100 tokenA (small relative to reserves)
            1,          // Minimum 1 tokenB out
            address(this)
        );
        assertTrue(out > 0, "Swap output should be greater than 0");
        
        // Verify we received tokens
        uint256 tokenBBalanceAfter = tokenB.balanceOf(address(this));
        assertTrue(tokenBBalanceAfter > tokenBBalanceBefore, "Should have received tokenB");
    }

    function testSwapRevertsWhenNoLiquidity() public {
        // Try to swap without adding liquidity first
        vm.expectRevert();
        router.swapExactTokensForTokens(
            address(tokenA), 
            address(tokenB), 
            1e18, 
            1, 
            address(this)
        );
    }

    function testSwapBothDirections() public {
        // Add substantial liquidity
        router.addLiquidity(
            address(tokenA), 
            address(tokenB), 
            10000e18, 
            20000e18, 
            1, 
            1, 
            address(this)
        );

        // Check initial balances
        uint256 initialTokenB = tokenB.balanceOf(address(this));
        uint256 initialTokenA = tokenA.balanceOf(address(this));

        // Swap A -> B
        uint256 outAB = router.swapExactTokensForTokens(
            address(tokenA), 
            address(tokenB), 
            100e18,    // 100 tokenA (small relative to reserves)
            1, 
            address(this)
        );
        assertTrue(outAB > 0, "A->B swap should work");
        assertTrue(tokenB.balanceOf(address(this)) > initialTokenB, "Should have more tokenB");

        // Swap B -> A  
        uint256 outBA = router.swapExactTokensForTokens(
            address(tokenB), 
            address(tokenA), 
            100e18,    // 100 tokenB (small relative to reserves)
            1, 
            address(this)
        );
        assertTrue(outBA > 0, "B->A swap should work");
        assertTrue(tokenA.balanceOf(address(this)) > initialTokenA - 100e18, "Should have more tokenA than after first swap");
    }

    function testGetAmountOut() public view {
        // This is a pure function, no need to add liquidity
        uint256 amountOut = router.getAmountOut(100e18, 10000e18, 20000e18);
        assertTrue(amountOut > 0, "Should calculate positive amount out");
        assertTrue(amountOut < 200e18, "Output should be less than 2x input due to fees");
    }

    function testLiquidityAndReserves() public {
        // Add liquidity
        router.addLiquidity(
            address(tokenA), 
            address(tokenB), 
            1000e18, 
            2000e18, 
            1, 
            1, 
            address(this)
        );

        address pair = factory.getPair(address(tokenA), address(tokenB));
        UniswapV2PairMinimal pairContract = UniswapV2PairMinimal(pair);
        
        (uint112 reserve0, uint112 reserve1, ) = pairContract.getReserves();
        
        // Check that reserves are approximately what we added (accounting for token sorting)
        uint256 totalReserves = uint256(reserve0) + uint256(reserve1);
        assertTrue(totalReserves >= 3000e18 - 100e18, "Total reserves should be approximately 3000 tokens");
        
        // Check individual reserves are reasonable
        assertTrue(reserve0 > 500e18, "Reserve0 should be substantial");
        assertTrue(reserve1 > 500e18, "Reserve1 should be substantial");
    }

    function testSmallSwapAfterLargeLiquidity() public {
        // Add very large liquidity
        router.addLiquidity(
            address(tokenA), 
            address(tokenB), 
            50000e18, 
            100000e18, 
            1, 
            1, 
            address(this)
        );

        // Perform a very small swap
        uint256 tokenBBefore = tokenB.balanceOf(address(this));
        
        uint256 out = router.swapExactTokensForTokens(
            address(tokenA), 
            address(tokenB), 
            1e18,     // Swap just 1 tokenA (very small)
            1, 
            address(this)
        );
        
        uint256 tokenBAfter = tokenB.balanceOf(address(this));
        assertTrue(out > 0, "Should get some output");
        assertTrue(tokenBAfter > tokenBBefore, "Should receive tokens");
    }
}