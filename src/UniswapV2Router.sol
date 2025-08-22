// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./UniswapV2Factory.sol";
import "./IERC20.sol";

contract UniswapV2Router {
    address public factory;

    constructor(address _factory) {
        factory = _factory;
    }

    function addLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB) external {
        address pair = UniswapV2Factory(factory).getPair(tokenA, tokenB);
        if (pair == address(0)) {
            pair = UniswapV2Factory(factory).createPair(tokenA, tokenB);
        }

        IERC20(tokenA).transferFrom(msg.sender, pair, amountA);
        IERC20(tokenB).transferFrom(msg.sender, pair, amountB);
        UniswapV2Pair(pair).mint(msg.sender);
    }

    function swapExactTokens(address tokenIn, address tokenOut, uint256 amountIn, address to) external {
        address pair = UniswapV2Factory(factory).getPair(tokenIn, tokenOut);
        require(pair != address(0), "Pair doesn't exist");

        IERC20(tokenIn).transferFrom(msg.sender, pair, amountIn);
        (uint112 reserve0, uint112 reserve1) = UniswapV2Pair(pair).getReserves();
        uint256 amountOut = getAmountOut(amountIn, reserve0, reserve1);
        UniswapV2Pair(pair).swap(
            tokenIn == UniswapV2Pair(pair).token0() ? amountOut : 0,
            tokenIn == UniswapV2Pair(pair).token1() ? amountOut : 0,
            to
        );
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256) {
        uint256 amountInWithFee = amountIn * 997;
        return (amountInWithFee * reserveOut) / (reserveIn * 1000 + amountInWithFee);
    }
}
