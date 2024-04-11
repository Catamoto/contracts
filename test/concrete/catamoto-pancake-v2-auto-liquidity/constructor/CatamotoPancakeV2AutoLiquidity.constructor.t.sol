// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Errors } from "src/libraries/Errors.sol";
import { IPancakeRouterV2 } from "src/IPancakeRouterV2.sol";
import { IPancakeFactoryV2 } from "src/IPancakeFactoryV2.sol";

import { CatamotoPancakeV2AutoLiquidity } from "src/CatamotoPancakeV2AutoLiquidity.sol";

import { CatamotoPancakeV2AutoLiquidityTest } from "test/CatamotoPancakeV2AutoLiquidityTest.sol";

contract CatamotoPancakeV2AutoLiquidity_constructor is CatamotoPancakeV2AutoLiquidityTest {
    function test_WhenToken0IsZeroAddress() external {
        // it reverts
        vm.expectRevert(abi.encodeWithSelector(Errors.UnacceptableReference.selector, address(0)));
        new CatamotoPancakeV2AutoLiquidity(IERC20(address(0)), token1, router, factory);
    }

    function test_WhenToken1IsZeroAddress() external {
        // it reverts
        vm.expectRevert(abi.encodeWithSelector(Errors.UnacceptableReference.selector, address(0)));
        new CatamotoPancakeV2AutoLiquidity(token0, IERC20(address(0)), router, factory);
    }

    function test_WhenRouterIsZeroAddress() external {
        // it reverts
        vm.expectRevert(abi.encodeWithSelector(Errors.UnacceptableReference.selector, address(0)));
        new CatamotoPancakeV2AutoLiquidity(token0, token1, IPancakeRouterV2(address(0)), factory);
    }

    function test_WhenFactoryIsZeroAddress() external {
        // it reverts
        vm.expectRevert(abi.encodeWithSelector(Errors.UnacceptableReference.selector, address(0)));
        new CatamotoPancakeV2AutoLiquidity(token0, token1, router, IPancakeFactoryV2(address(0)));
    }

    function test_GivenTokenHasBeenDeployed() external {
        // it deploys token with given arguments
        consumer = new CatamotoPancakeV2AutoLiquidity(token0, token1, router, factory);

        assertEq(address(consumer.token0()), address(token0), "it sets token0 address");
        assertEq(address(consumer.token1()), address(token1), "it sets token1 address");
        assertEq(address(consumer.router()), address(router), "it sets router address");
        assertEq(address(consumer.factory()), address(factory), "it sets factory address");
    }
}
