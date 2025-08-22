// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./UniswapV2Pair.sol";
import "./IERC20.sol";

contract UniswapV2Factory {
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair);

    modifier onlyUniquePairs(address tokenA, address tokenB) {
        require(tokenA != tokenB, "Identical addresses");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(getPair[token0][token1] == address(0), "Pair exists");
        _;
    }

    function createPair(address tokenA, address tokenB)
        external
        onlyUniquePairs(tokenA, tokenB)
        returns (address pair)
    {
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(tokenA, tokenB));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        UniswapV2Pair(pair).initialize(tokenA, tokenB);
        getPair[tokenA][tokenB] = pair;
        getPair[tokenB][tokenA] = pair; // bi-directional
        allPairs.push(pair);
        emit PairCreated(tokenA, tokenB, pair);
    }
}
