# xstock-payback-vault

A Solidity project built with [Foundry](https://book.getfoundry.sh/).

## Contracts

### `PaybackMarketVault`

A vault that allows approved callers to buy tokenized assets (e.g. xStocks) using USDC at a fixed oracle price.

- **Owner** sets approved callers and assigns a price oracle per token.
- **`buy(token, inputAmount)`** — transfers USDC from the caller to the owner and sends the corresponding token amount back to the caller, priced via the oracle.
- **`recoverERC20(token)`** — lets the owner withdraw any ERC20 tokens held by the vault.

### `IFixedPriceAdapter`

Interface for a fixed-price oracle adapter. Returns a hardcoded price and its decimals, used by `PaybackMarketVault` to calculate token output amounts.

## Usage

```shell
forge build
forge test
forge fmt
```
