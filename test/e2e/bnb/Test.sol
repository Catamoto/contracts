// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Catamoto } from "src/Catamoto.sol";
import { CatamotoPancakeV2Buyback } from "src/CatamotoPancakeV2Buyback.sol";
import { CatamotoPancakeV2AutoLiquidity } from "src/CatamotoPancakeV2AutoLiquidity.sol";

import {
    CatamotoDeploymentBNB,
    WETH,
    TENSET,
    PANCAKE_ROUTER_V2,
    PANCAKE_FACTORY_V2
} from "script/CatamotoDeployment.bnb.s.sol";

import { Test as TestCase } from "test/Test.sol";
import { ITenset } from "test/e2e/bnb/ITenset.sol";
import { IPancakeRouterV2 } from "test/e2e/bnb/IPancakeRouterV2.sol";
import { IPancakeFactoryV2 } from "test/e2e/bnb/IPancakeFactoryV2.sol";

abstract contract Test is TestCase {
    IERC20 internal weth = IERC20(WETH);
    ITenset internal tenset = ITenset(TENSET);

    Catamoto internal token;

    IPancakeRouterV2 router = IPancakeRouterV2(PANCAKE_ROUTER_V2);
    IPancakeFactoryV2 factory = IPancakeFactoryV2(PANCAKE_FACTORY_V2);

    CatamotoPancakeV2AutoLiquidity internal consumer0;
    CatamotoPancakeV2Buyback internal consumer1;

    uint256 internal constant LIQUIDITY_0 = 100 ether;
    uint256 internal constant LIQUIDITY_1 = 100_000_000 ether;

    function setUp() public virtual {
        (, deployer,) = vm.readCallers();

        string memory url = vm.envOr("TEST_BNB_RPC_URL", string("https://bsc-dataseed2.bnbchain.org"));

        uint256 fork = vm.createFork(url);

        vm.selectFork(fork);

        CatamotoDeploymentBNB script = new CatamotoDeploymentBNB();

        (token, consumer0, consumer1) = script.run();

        vm.prank(tenset.owner());
        tenset.setExcludedFee(address(consumer1), true);
    }
}
