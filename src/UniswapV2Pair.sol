// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IERC20.sol";

contract UniswapV2Pair {
    address public token0;
    address public token1;
    uint112 public reserve0;
    uint112 public reserve1;

    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amountIn, uint256 amountOut, address indexed to);

    function initialize(address _token0, address _token1) external {
        require(token0 == address(0) && token1 == address(0), "Already initialized");
        token0 = _token0;
        token1 = _token1;
    }

    function _update(uint256 balance0, uint256 balance1) private {
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
    }

    function getReserves() external view returns (uint112, uint112) {
        return (reserve0, reserve1);
    }

    function mint(address to) external returns (uint256 liquidity) {
        (uint112 _reserve0, uint112 _reserve1) = (reserve0, reserve1);
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 - _reserve1;

        liquidity = sqrt(amount0 * amount1);
        require(liquidity > 0, "Insufficient liquidity");
        balanceOf[to] += liquidity;
        totalSupply += liquidity;

        _update(balance0, balance1);
        emit Mint(msg.sender, amount0, amount1);
    }

    function swap(uint256 amountOut0, uint256 amountOut1, address to) external {
        require(amountOut0 > 0 || amountOut1 > 0, "Insufficient output amount");
        require(amountOut0 < reserve0 && amountOut1 < reserve1, "Insufficient liquidity");

        if (amountOut0 > 0) IERC20(token0).transfer(to, amountOut0);
        if (amountOut1 > 0) IERC20(token1).transfer(to, amountOut1);

        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));

        _update(balance0, balance1);
        emit Swap(msg.sender, amountOut0 + amountOut1, 0, to);
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
