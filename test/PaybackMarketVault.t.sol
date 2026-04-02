// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {PaybackMarketVault} from "../src/PaybackMarketVault.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {IFixedPriceAdapter} from "../src/interfaces/IFixedPriceAdapter.sol";
import {console2} from "forge-std/console2.sol";

contract MyERC20Mock is ERC20Mock {
    uint8 private immutable _decimals;
    constructor(uint8 decimals_) {
        _decimals = decimals_;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}

contract CounterTest is Test {
    PaybackMarketVault public paybackMarketVault;

    address public wspyx;
    // address public wspyx = 0x9eF9f9B22d3CA9769e28e769e2AAA3C2B0072D0e;
    address public wspyxOracle = 0x65A677254a598C8e9eD31df793296E73752550ca;
    address public wqqqx;
    // address public wqqqx = 0x267ED9BC43B16D832cB9Aaf0e3445f0cC9f536d9;
    address public wqqqxOracle = 0x1a4c9eB0845CD2746cFc552c0494d9bba2905baA;
    // address public usdc = 0x6b57475467cd854d36Be7FB614caDa5207838943;
    address public usdc;

    address caller = makeAddr("caller");

    function setUp() public {
        vm.createSelectFork("https://rpc-gel-sepolia.inkonchain.com");
        usdc = address(new MyERC20Mock(6));
        wspyx = address(new MyERC20Mock(18));
        wqqqx = address(new MyERC20Mock(18));

        MyERC20Mock(wspyx).mint(address(this), 1000000000000000000000000000);
        MyERC20Mock(wqqqx).mint(address(this), 1000000000000000000000000000);
        MyERC20Mock(usdc).mint(caller, 1000000000000000000000000000);

        paybackMarketVault = new PaybackMarketVault(address(this), usdc);
        paybackMarketVault.setOracle(wspyx, wspyxOracle);
        paybackMarketVault.setOracle(wqqqx, wqqqxOracle);
        paybackMarketVault.setApprovedCaller(caller, true);
        ERC20Mock(wqqqx).transfer(address(paybackMarketVault), 1000000000000000000000000);
    }

    function test_buy() public {
        int256 price = IFixedPriceAdapter(wqqqxOracle).price();
        uint8 decimals = IFixedPriceAdapter(wqqqxOracle).decimals();
        assertEq(price, 2557000000);
        assertEq(decimals, 8);

        uint256 inputAmount = 10e6;
        uint256 outputAmount = inputAmount * 10 ** (decimals + 18 - 6) / uint256(price);
        uint256 initialCallerUsdcBalance = ERC20Mock(usdc).balanceOf(caller);
        uint256 initialOwnerUsdcBalance = ERC20Mock(usdc).balanceOf(address(this));
        uint256 initialVaultWqqqxBalance = ERC20Mock(wqqqx).balanceOf(address(paybackMarketVault));

        vm.startPrank(caller);
        ERC20Mock(usdc).approve(address(paybackMarketVault), inputAmount);
        paybackMarketVault.buy(wqqqx, inputAmount);

        assertEq(ERC20Mock(usdc).balanceOf(caller), initialCallerUsdcBalance - inputAmount);
        assertEq(ERC20Mock(wqqqx).balanceOf(caller), outputAmount);
        assertEq(ERC20Mock(usdc).balanceOf(address(this)), initialOwnerUsdcBalance + inputAmount);
        assertEq(ERC20Mock(wqqqx).balanceOf(address(paybackMarketVault)), initialVaultWqqqxBalance - outputAmount);

        console2.log("inputAmount", inputAmount);
        console2.log("outputAmount", outputAmount);
    }
}
