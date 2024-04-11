// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { IPancakeRouterV2 } from "src/IPancakeRouterV2.sol";
import { IPancakeFactoryV2 } from "src/IPancakeFactoryV2.sol";
import { CatamotoPancakeV2AutoLiquidity } from "src/CatamotoPancakeV2AutoLiquidity.sol";

import { Test } from "test/Test.sol";
import { ERC20Sample } from "test/samples/ERC20Sample.sol";
import { PancakeRouterV2Mock } from "test/mocks/PancakeRouterV2Mock.sol";
import { PancakeFactoryV2Mock } from "test/mocks/PancakeFactoryV2Mock.sol";

abstract contract CatamotoPancakeV2AutoLiquidityTest is Test {
    address internal bypassed = makeAddr("bypassed");

    IERC20 internal token0 = new ERC20Sample();
    IERC20 internal token1 = new ERC20Sample();

    IPancakeRouterV2 internal router = new PancakeRouterV2Mock();
    IPancakeFactoryV2 internal factory = new PancakeFactoryV2Mock();

    CatamotoPancakeV2AutoLiquidity internal consumer;

    function fixture() public returns (CatamotoPancakeV2AutoLiquidity) {
        return fixture(token0, token1, router, factory);
    }

    function fixture(IERC20 token0_, IERC20 token1_, IPancakeRouterV2 router_, IPancakeFactoryV2 factory_)
        public
        returns (CatamotoPancakeV2AutoLiquidity)
    {
        return
            new CatamotoPancakeV2AutoLiquidity(token0 = token0_, token1 = token1_, router = router_, factory = factory_);
    }
}
