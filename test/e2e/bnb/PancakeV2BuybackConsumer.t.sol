// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { Vm } from "forge-std/Vm.sol";

import { ICatamotoTaxConsumer } from "src/ICatamotoTaxConsumer.sol";

import { Test } from "test/e2e/bnb/Test.sol";

contract PancakeV2BuybackConsumer is Test {
    function setUp() public override {
        super.setUp();

        deal(address(weth), alice, 1 ether);
        deal(address(token), alice, 1 ether);

        vm.startPrank(deployer);

        deal(address(weth), deployer, LIQUIDITY_0);

        weth.approve(address(router), LIQUIDITY_0);
        token.approve(address(router), LIQUIDITY_1);

        router.addLiquidity(
            address(weth), address(token), LIQUIDITY_0, LIQUIDITY_1, 0, 0, deployer, block.timestamp + 200
        );

        vm.stopPrank();
    }

    function test_consumerExecutesBuybackByTransfer(uint32 divider) external {
        vm.assume(divider > 0 && divider < 100);

        uint256 amount = token.balanceOf(alice) / divider;

        uint256 balance = tenset.balanceOf(address(consumer1));

        vm.expectEmit(false, false, false, false);
        emit ICatamotoTaxConsumer.Executed();

        vm.prank(alice);

        token.transfer(bob, amount);

        assertGt(tenset.balanceOf(address(consumer1)), balance);
    }

    function test_consumerExecutesBuybackBySwap0(uint32 divider) external {
        vm.assume(divider > 0 && divider < 100);

        uint256 amount = token.balanceOf(alice) / divider;

        uint256 balance = tenset.balanceOf(address(consumer1));

        address[] memory swap = new address[](2);
        (swap[0], swap[1]) = (address(token), address(weth));

        vm.startPrank(alice);
        token.approve(address(router), amount);

        vm.expectEmit(false, false, false, false);
        emit ICatamotoTaxConsumer.Executed();

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, swap, alice, block.timestamp);

        assertGt(tenset.balanceOf(address(consumer1)), balance);
    }

    function test_consumerDoseNotExecuteBuybackBySwap1(uint32 divider) external {
        vm.assume(divider > 0 && divider < 100);

        uint256 amount = weth.balanceOf(alice) / divider;

        uint256 balance = tenset.balanceOf(address(consumer1));

        address[] memory swap = new address[](2);
        (swap[0], swap[1]) = (address(weth), address(token));

        vm.startPrank(alice);
        weth.approve(address(router), amount);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, swap, alice, block.timestamp);

        assertEq(tenset.balanceOf(address(consumer1)), balance);
    }

    function test_consumerDoseNotExecuteBuybackBySwap0WhenCallerIsHasExecutionBypassRole(uint32 divider) external {
        vm.assume(divider > 0 && divider < 100);

        uint256 amount = token.balanceOf(alice) / divider;

        uint256 balance = tenset.balanceOf(address(consumer1));

        vm.startPrank(deployer);
        consumer1.grantRole(keccak256("EXECUTION_BYPASS_ROLE"), alice);

        address[] memory swap = new address[](2);
        (swap[0], swap[1]) = (address(token), address(weth));

        vm.startPrank(alice);
        token.approve(address(router), amount);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, swap, alice, block.timestamp);

        assertEq(tenset.balanceOf(address(consumer1)), balance);
    }

    function test_consumerDoseNotExecuteBuybackBySwap1WhenCallerIsHasExecutionBypassRole(uint32 divider) external {
        vm.assume(divider > 0 && divider < 100);

        uint256 amount = weth.balanceOf(alice) / divider;

        uint256 balance = tenset.balanceOf(address(consumer1));

        vm.startPrank(deployer);
        consumer1.grantRole(keccak256("EXECUTION_BYPASS_ROLE"), alice);

        address[] memory swap = new address[](2);
        (swap[0], swap[1]) = (address(weth), address(token));

        vm.startPrank(alice);
        weth.approve(address(router), amount);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, swap, alice, block.timestamp);

        assertEq(tenset.balanceOf(address(consumer1)), balance);
    }

    function test_ownerCanWithdrawToken1(uint32 divider) external {
        vm.assume(divider > 0 && divider < 100);

        uint256 amount = weth.balanceOf(alice) / divider;

        uint256 balance = tenset.balanceOf(deployer);

        vm.prank(alice);

        token.transfer(bob, amount);

        assertGt(tenset.balanceOf(address(consumer1)), balance);

        uint256 amountOut = tenset.balanceOf(deployer);

        vm.startPrank(deployer);
        consumer1.withdrawToken(deployer, tenset, amountOut);

        assertEq(tenset.balanceOf(deployer), amountOut);
    }
}
