// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "forge-std/Script.sol";

import { Catamoto } from "src/Catamoto.sol";

import { IPancakeRouterV2 } from "src/IPancakeRouterV2.sol";
import { IPancakeFactoryV2 } from "src/IPancakeFactoryV2.sol";

import { Catamoto } from "src/Catamoto.sol";
import { CatamotoPancakeV2Buyback } from "src/CatamotoPancakeV2Buyback.sol";
import { CatamotoPancakeV2AutoLiquidity } from "src/CatamotoPancakeV2AutoLiquidity.sol";

import { CatamotoDeployer } from "script/CatamotoDeployer.s.sol";

address constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
address constant TENSET = 0x1AE369A6AB222aFF166325B7b87Eb9aF06C86E57;
address constant PANCAKE_ROUTER_V2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
address constant PANCAKE_FACTORY_V2 = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

contract CatamotoDeploymentBNB is CatamotoDeployer {
    function run() external returns (Catamoto, CatamotoPancakeV2AutoLiquidity, CatamotoPancakeV2Buyback) {
        vm.startBroadcast();

        token("Catamoto", "CATA", 20_000_000_000 * 10 ** 18);

        CatamotoPancakeV2AutoLiquidity consumer0 = new CatamotoPancakeV2AutoLiquidity(
            catamoto, IERC20(WETH), IPancakeRouterV2(PANCAKE_ROUTER_V2), IPancakeFactoryV2(PANCAKE_FACTORY_V2)
        );

        catamoto.grantRole(keccak256("UNTAXED_ROLE"), address(consumer0));
        catamoto.updateTax0Consumer(consumer0);

        consumer0.grantRole(keccak256("EXECUTOR_ROLE"), address(catamoto));

        CatamotoPancakeV2Buyback consumer1 = new CatamotoPancakeV2Buyback(
            catamoto,
            IERC20(WETH),
            IERC20(TENSET),
            IPancakeRouterV2(PANCAKE_ROUTER_V2),
            IPancakeFactoryV2(PANCAKE_FACTORY_V2)
        );

        catamoto.grantRole(keccak256("UNTAXED_ROLE"), address(consumer1));
        catamoto.updateTax1Consumer(consumer1);

        consumer1.grantRole(keccak256("EXECUTOR_ROLE"), address(catamoto));

        vm.stopBroadcast();

        return (catamoto, consumer0, consumer1);
    }
}
