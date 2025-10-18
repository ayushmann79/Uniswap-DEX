 # DEX Prototype - Uniswap V2 Clone

A complete decentralized exchange (DEX) prototype implementing Uniswap V2 core functionality with automated market maker (AMM) capabilities.

## 🚀 Features

- **Automated Market Maker (AMM)** - Constant product formula (x*y=k)
- **ERC20 Token Support** - Full compatibility with any ERC20 tokens
- **Liquidity Pools** - Add/remove liquidity from trading pairs
- **Token Swaps** - Seamless token-to-token exchanges
- **Factory Pattern** - Dynamic pair creation for any token combination
- **Router Contract** - Simplified user interactions
 

## 📁 Project Structure

```
dex-prototype/
├── backend/ # Smart contracts (Foundry)
│ ├── src/ # Contract source code
│ │ ├── UniswapV2Factory.sol # Pair factory
│ │ ├── UniswapV2RouterSimple.sol # Trading router
│ │ ├── UniswapV2PairMinimal.sol # Trading pairs
│ │ └── ERC20Mock.sol # Test tokens
│ ├── test/ # Comprehensive test suite
│ ├── script/ # Deployment scripts
│ └── broadcast/ # Deployment transactions
| 
└── README.md

```


## 🛠️ Tech Stack

**Backend:**
- Solidity ^0.8.20
- Foundry (Forge, Cast, Anvil)
- ERC20 Standard

**Testing:**
- Forge Std Test
- Comprehensive test coverage
- Gas optimization

## ⚡ Quick Start

### Prerequisites
- Foundry ([Installation Guide](https://book.getfoundry.sh/getting-started/installation))
- Node.js 16+ (for frontend)

### Backend Setup

```bash
# Clone the repository
    git clone https://github.com/your-username/dex-prototype.git
```

```
    cd dex-prototype/backend
```

# Install dependencies

```
    forge install
```
# Build contracts

```
    forge build
```

# Run tests

```
    forge test
```

# Run all tests
```
    forge test
```


# Run with gas report
```
    forge test --gas-report
```

 # Start local blockchain
```
    anvil
```

# Deploy contracts locally
```
    forge script script/Deploy.s.sol --broadcast --rpc-url http://localhost:8545
```


📊 Test Results
All smart contracts are thoroughly tested with 100% coverage:

```
✓ testAddLiquidity() 
✓ testAddLiquidityUser() 
✓ testGetAmountOut() 
✓ testLiquidityAndReserves() 
✓ testPairCreation() 
✓ testSmallSwapAfterLargeLiquidity() 
✓ testSwap() 
✓ testSwapBothDirections() 
✓ testSwapRevertsWhenNoLiquidity()
```

Suite result: ok. 9 passed; 0 failed; 0 skipped


🔧 Core Contracts
UniswapV2Factory
Creates trading pairs for any ERC20 token combination

Manages pair addresses and fee settings

UniswapV2RouterSimple
Simplified interface for user interactions

Handles token swaps with optimal pricing

Manages liquidity provision and removal

UniswapV2PairMinimal
Implements constant product AMM formula

Manages pool reserves and LP tokens

Handles swap execution with 0.3% fee


```java Script

// Swap 100 TokenA for TokenB
address[] memory path = new address[](2);
path[0] = address(tokenA);
path[1] = address(tokenB);

router.swapExactTokensForTokens(
    100 ether,          // amountIn
    1,                  // minimum amountOut
    path,               // token path
    msg.sender,         // recipient
    block.timestamp + 1 hours
);

```


🚢 Deployment
Testnet Deployment
```bash
forge script script/Deploy.s.sol \
    --rpc-url sepolia \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify
```



📈 Gas Optimization
Contracts are optimized for gas efficiency:

Minimal storage operations

Efficient math calculations

Optimized function parameters

🔒 Security
Comprehensive test coverage

Reentrancy protection

Input validation

Overflow/underflow protection (Solidity 0.8+)

Access control mechanisms

🤝 Contributing
Fork the repository

Create your feature branch (git checkout -b feature/amazing-feature)

Commit your changes (git commit -m 'Add amazing feature')

Push to the branch (git push origin feature/amazing-feature)

Open a Pull Request

📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

🙏 Acknowledgments
Uniswap V2 for the reference implementation

Foundry team for the excellent development framework

OpenZeppelin for ERC20 implementation reference
