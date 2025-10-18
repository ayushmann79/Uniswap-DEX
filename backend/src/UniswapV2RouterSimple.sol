// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {UniswapV2PairMinimal} from "./UniswapV2PairMinimal.sol";

interface IFactory {
    function getPair(address tokenA, address tokenB) external view returns (address);
}

contract UniswapV2RouterSimple {
    address public immutable FACTORY;
    
    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "REENTRANCY");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor(address _factory) {
        FACTORY = _factory;
    }

    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal view returns (uint256 amountA, uint256 amountB) {
        address pair = IFactory(FACTORY).getPair(tokenA, tokenB);
        require(pair != address(0), "PAIR_DOES_NOT_EXIST");
        
        (uint256 reserveA, uint256 reserveB, ) = UniswapV2PairMinimal(pair).getReserves();
        
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = _quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "INSUFFICIENT_B_AMOUNT");
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = _quote(amountBDesired, reserveB, reserveA);
                require(amountAOptimal <= amountADesired, "UNEXPECTED");
                require(amountAOptimal >= amountAMin, "INSUFFICIENT_A_AMOUNT");
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to
    ) external lock returns (uint256 liquidity) {
        (uint256 amountA, uint256 amountB) = _addLiquidity(
            tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin
        );
        
        address pair = IFactory(FACTORY).getPair(tokenA, tokenB);
        
        // Transfer tokens to pair
        _safeTransferFrom(tokenA, msg.sender, pair, amountA);
        _safeTransferFrom(tokenB, msg.sender, pair, amountB);
        
        liquidity = UniswapV2PairMinimal(pair).mint(to);
        return liquidity;
    }

    function swapExactTokensForTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address to
    ) external lock returns (uint256 amountOut) {
        address pair = IFactory(FACTORY).getPair(tokenIn, tokenOut);
        require(pair != address(0), "PAIR_DOES_NOT_EXIST");

        // Transfer tokens to pair
        _safeTransferFrom(tokenIn, msg.sender, pair, amountIn);
        
        UniswapV2PairMinimal pairContract = UniswapV2PairMinimal(pair);

        (uint112 reserve0, uint112 reserve1, ) = pairContract.getReserves();
        
        // Determine the correct reserve order
        (uint256 reserveIn, uint256 reserveOut) = tokenIn == pairContract.token0() 
            ? (reserve0, reserve1) 
            : (reserve1, reserve0);
        
        amountIn = IERC20(tokenIn).balanceOf(pair) - reserveIn; // Get actual amount transferred
        amountOut = getAmountOut(amountIn, reserveIn, reserveOut);
        
        require(amountOut >= amountOutMin, "INSUFFICIENT_OUTPUT_AMOUNT");

        (uint256 amount0Out, uint256 amount1Out) = tokenIn == pairContract.token0() 
            ? (uint256(0), amountOut) 
            : (amountOut, uint256(0));
            
        pairContract.swap(amount0Out, amount1Out, to);
        return amountOut;
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) 
        public 
        pure 
        returns (uint256 amountOut) 
    {
        require(amountIn > 0, "INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn * 997;
        amountOut = (amountInWithFee * reserveOut) / (reserveIn * 1000 + amountInWithFee);
    }

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) 
        public 
        pure 
        returns (uint256 amountIn) 
    {
        require(amountOut > 0, "INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn * amountOut * 1000;
        uint256 denominator = (reserveOut - amountOut) * 997;
        amountIn = (numerator / denominator) + 1;
    }

    function _quote(uint256 amountA, uint256 reserveA, uint256 reserveB) internal pure returns (uint256 amountB) {
        require(amountA > 0, "INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "INSUFFICIENT_LIQUIDITY");
        amountB = (amountA * reserveB) / reserveA;
    }

    function _safeTransferFrom(address token, address from, address to, uint256 value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FROM_FAILED");
    }
}