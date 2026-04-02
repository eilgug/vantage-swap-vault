// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {PaybackMarketVault} from "../src/PaybackMarketVault.sol";
import {console2} from "forge-std/console2.sol";

contract PaybackMarketVaultScript is Script {
    address public constant WSPYX = 0x9eF9f9B22d3CA9769e28e769e2AAA3C2B0072D0e;
    address public constant WSPYX_ORACLE = 0x65A677254a598C8e9eD31df793296E73752550ca;
    address public constant WQQQX = 0x267ED9BC43B16D832cB9Aaf0e3445f0cC9f536d9;
    address public constant WQQQX_ORACLE = 0x1a4c9eB0845CD2746cFc552c0494d9bba2905baA;
    address public constant USDC = 0x6b57475467cd854d36Be7FB614caDa5207838943;

    PaybackMarketVault public paybackMarketVault;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        paybackMarketVault = new PaybackMarketVault(msg.sender, USDC);
        paybackMarketVault.setOracle(WSPYX, WSPYX_ORACLE);
        paybackMarketVault.setOracle(WQQQX, WQQQX_ORACLE);

        vm.stopBroadcast();

        console2.log("PaybackMarketVault deployed to", address(paybackMarketVault));
    }
}
