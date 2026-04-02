// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";
import {IFixedPriceAdapter} from "./interfaces/IFixedPriceAdapter.sol";

contract PaybackMarketVault is Ownable {
    IERC20 public immutable usdc;
    uint8 internal constant INPUT_TOKEN_DECIMALS = 6;
    uint8 internal constant OUTPUT_TOKEN_DECIMALS = 18;

    mapping(address => bool) public isApprovedCaller;
    mapping(address => address) public oracles;

    constructor(address owner_, address usdc_) Ownable(owner_) {
        usdc = IERC20(usdc_);
    }

    function setApprovedCaller(address caller, bool isApproved) public onlyOwner {
        isApprovedCaller[caller] = isApproved;
    }

    function setOracle(address token, address oracle) public onlyOwner {
        oracles[token] = oracle;
    }

    function buy(address token, uint256 inputAmount) public {
        require(isApprovedCaller[msg.sender], "Caller not approved");
        require(inputAmount > 0, "Input amount must be greater than 0");

        IFixedPriceAdapter oracle = IFixedPriceAdapter(oracles[token]);
        require(address(oracle) != address(0), "Oracle not set");

        int256 price = oracle.price();
        require(price > 0, "Price not set");

        uint256 outputAmount =
            inputAmount * 10 ** (oracle.decimals() + OUTPUT_TOKEN_DECIMALS - INPUT_TOKEN_DECIMALS) / uint256(price);
        require(outputAmount > 0, "Output amount must be greater than 0");

        usdc.transferFrom(msg.sender, owner(), inputAmount);
        IERC20(token).transfer(msg.sender, outputAmount);
    }

    function recoverERC20(address token) public onlyOwner {
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(owner(), amount);
    }
}
