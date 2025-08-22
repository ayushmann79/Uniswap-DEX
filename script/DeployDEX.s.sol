// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/UniswapV2Factory.sol";
import "../src/UniswapV2Router.sol";
import "../src/ERC20.sol";

contract Deploy {
    UniswapV2Factory public factory;
    UniswapV2Router public router;
    ERC20 public tokenA;
    ERC20 public tokenB;

    function run() external {
        factory = new UniswapV2Factory();
        router = new UniswapV2Router(address(factory));

        tokenA = new ERC20("Token A", "TKA", 1_000_000 ether);
        tokenB = new ERC20("Token B", "TKB", 1_000_000 ether);

        // Approvals and liquidity can be added in test or script context.
    }
}
