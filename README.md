Project Overview:
This project is an implementation of a Decentralized Exchange (DEX) similar to Uniswap, where you can add liquidity and swap tokens between two different ERC-20 tokens. The core components of this project include:

ERC-20 Tokens (Token A and Token B),

Uniswap V2 Factory (which creates and manages pairs),

Uniswap V2 Router (handles liquidity addition and token swapping),

Uniswap V2 Pair (holds the liquidity for each token pair).

The test (DEXTest) verifies if adding liquidity and swapping tokens works as expected. It checks token balances before and after the liquidity addition and swap, and compares them with the expected values.

Key Concepts:
Liquidity Pools:

Liquidity pools are pools of tokens in a smart contract that allow users to trade between different tokens. Users can add liquidity to these pools by depositing an equal value of both tokens (e.g., 100 TKA and 100 TKB in this case).

In this DEX, liquidity is added using the addLiquidity() function. When liquidity is added, it’s stored in a pair contract that represents the trading pair between two tokens.

Swapping Tokens:

Swapping refers to exchanging one token for another. This is done using the swapExactTokens() function in the UniswapV2Router.

When a user swaps a token (e.g., TKA) for another token (e.g., TKB), the smart contract performs calculations to determine how many tokens the user will receive based on the reserves in the liquidity pool (a.k.a. the Automated Market Maker or AMM algorithm).

Liquidity Providers (LPs):

Users who provide liquidity to a pool are called Liquidity Providers (LPs). In return for providing liquidity, LPs receive LP tokens that represent their share of the pool.

For example, adding 100 TKA and 100 TKB would give you LP tokens proportional to the liquidity you provided.

Gas Fees:

Gas fees are the costs associated with executing transactions or smart contract operations on Ethereum. Each transaction and operation consumes a certain amount of computational resources, measured in "gas."

Adding liquidity and swapping tokens consume gas because they require interacting with multiple smart contracts.

Swap Fee: Each swap also includes a fee (often around 0.3% in Uniswap-like models), which helps incentivize liquidity providers.

Code Walkthrough:
1. ERC-20 Token Contract
The ERC20.sol file implements the ERC-20 token standard for Token A and Token B. These tokens are used for adding liquidity and swapping.

The ERC20 contract has functions like transfer(), balanceOf(), and approve(), which allow the transfer of tokens and approval for spending.

2. UniswapV2Factory.sol
The factory contract is responsible for creating new trading pairs between two tokens and managing all pair contracts.

createPair(address tokenA, address tokenB) is the function that creates a pair of tokens if they don’t exist already. A new contract of type UniswapV2Pair is deployed, which holds the liquidity for this token pair.

getPair(address tokenA, address tokenB) returns the address of the pair contract for a given token pair.

3. UniswapV2Router.sol
This contract is where all interactions with liquidity pools and swaps happen.

The addLiquidity() function allows users to add tokens to the pool. It first checks if the pair exists; if not, it creates the pair using the createPair() function from the factory.

It then transfers the specified amounts of tokenA and tokenB to the pair contract and mints the LP tokens, which represent the liquidity provided.

swapExactTokens() swaps one token for another (from tokenIn to tokenOut). It performs the following:

Transfers tokens from the user to the liquidity pool (pair contract).

Calls the getReserves() function of the pair contract to check the available reserves of the two tokens.

Uses the AMM formula to calculate how many tokens the user should receive based on the amount they are swapping.

Executes the swap by calling the swap() function on the pair contract, transferring the swapped tokens to the user.

AMM Formula: The core of the swap is the Automated Market Maker (AMM) formula that Uniswap uses:

AmountOut
=
AmountIn
×
ReserveOut
ReserveIn
+
AmountIn
AmountOut= 
ReserveIn+AmountIn
AmountIn×ReserveOut
​
 
This formula ensures that the ratio of tokens in the pool is maintained after each swap. It also accounts for fees (usually 0.3%) taken from the swap.

4. UniswapV2Pair.sol
The pair contract is where the actual liquidity resides for each token pair.

The getReserves() function returns the current reserves of both tokens in the pool. This information is critical for the swap function to determine how much of the output token the user will receive.

The mint() function is called when liquidity is added, and it mints LP tokens to the liquidity provider.

The swap() function is called during token swaps to move the tokens in and out of the pair contract.

5. DEXTest.sol (Test Contract)
This is the test contract where you verify the functionality of adding liquidity and performing swaps.

Test Setup (setUp):

Token Initialization: Two tokens (Token A and Token B) are created and allocated to the user.

Allowance: The user approves the router contract to spend the tokens on their behalf using approve().

Factory and Router Setup: The UniswapV2Factory and UniswapV2Router are deployed.

User Approval: The user is set up to be able to call the router contract for adding liquidity and swapping tokens.

Test Function (testAddLiquidityAndSwap):

Add Liquidity: The user adds 100 of both tokenA and tokenB to the liquidity pool via addLiquidity().

Swap Tokens: The user swaps 10 tokenA for tokenB using swapExactTokens().

Balance Assertions: After the swap, the balances of tokenA and tokenB are checked to ensure the user has received the correct amount of tokenB and the remaining tokenA balance has decreased appropriately.

Why Token A and B are Used for Balances:

The test verifies that when liquidity is added and tokens are swapped, the balances change according to the expectations based on the AMM formula.

Token A is used as the input for swaps, and the result is Token B, so after the swap, the balances of these two tokens for the user are checked.

Tolerance: We used tolerance because floating-point calculations (especially with Ethereum gas fees, slippage, etc.) may cause slight differences in actual token amounts.

Why We Used Custom Balance Checking:
In testing, especially with token transfers and swaps, small errors or rounding discrepancies can happen due to various factors such as:

Slippage: This occurs when the price changes between the time the transaction is submitted and when it is confirmed.

Gas Fees: The fees can slightly reduce the amount of tokens the user receives after a transaction.

By using a tolerance range, we allow for small errors due to these factors without failing the test.

Gas Calculation:
Gas costs are associated with each interaction, whether it's adding liquidity or swapping tokens.

Each call to a function (e.g., addLiquidity(), swapExactTokens()) consumes gas depending on:

The complexity of the operations (e.g., math for swaps, token transfers, etc.),

The number of storage changes (e.g., updating balances and reserves in the contract).

Gas is calculated automatically by the Ethereum Virtual Machine (EVM) and charged in gwei.

Conclusion:
This project replicates the core functionality of a DEX like Uniswap, where users can add liquidity and swap tokens. The test checks if these operations behave as expected, including the gas considerations, slippage, and correct token balances after operations.

```
    clone the repo
    git clone https://github.com/ayushmann79/Uniswap-DEX.git
```

```
    enter the project
    cd Uniswap-DEX
```

```
    install submodules / dependencies
    forge install
```

```
    compile contracts
    forge build
```
```
    run tests
    forge test -vv
```