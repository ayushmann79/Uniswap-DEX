// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/Script.sol";
import "../src/UniswapV2Factory.sol";
import "../src/UniswapV2Router.sol";
import "../src/ERC20.sol";
import "../src/IERC20.sol";
import "../src/UniswapV2Pair.sol";

contract DEXTest is Test {
    UniswapV2Factory factory;
    UniswapV2Router router;
    ERC20 tokenA;
    ERC20 tokenB;
    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        factory = new UniswapV2Factory();
        router = new UniswapV2Router(address(factory));
        tokenA = new ERC20("Token A", "TKA", 1_000_000 ether);
        tokenB = new ERC20("Token B", "TKB", 1_000_000 ether);
    }

    function testCreatePair() public {
        address pair = factory.createPair(address(tokenA), address(tokenB));
        assertEq(pair, factory.getPair(address(tokenA), address(tokenB)));
        assertEq(pair, factory.getPair(address(tokenB), address(tokenA))); // bi-directional
    }

    function testAddLiquidity() public {
        tokenA.approve(address(router), type(uint256).max);
        tokenB.approve(address(router), type(uint256).max);

        router.addLiquidity(address(tokenA), address(tokenB), 100 ether, 100 ether);

        (uint112 reserveA, uint112 reserveB) =
            UniswapV2Pair(factory.getPair(address(tokenA), address(tokenB))).getReserves();
        assertEq(reserveA, 100 ether);
        assertEq(reserveB, 100 ether);
    }
}
