// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { Test } from "test/e2e/bnb/Test.sol";

contract PancakeV2PoolDuringSupervisedTransfersPeriod is Test {
    function setUp() public override {
        super.setUp();

        deal(address(weth), deployer, LIQUIDITY_0);

        vm.startPrank(deployer);
        token.updateSupervisedTransfersEndAt(uint64(vm.unixTime()));
        token.grantRole(keccak256("ALLOWED_TO_TRANSFER_EARLY_ROLE"), deployer);
    }

    function test_authorizedCanCreatePancakeSwapPool() external {
        weth.approve(address(router), LIQUIDITY_0);
        token.approve(address(router), LIQUIDITY_1);

        (uint256 liquidity0, uint256 liquidity1,) = router.addLiquidity(
            address(weth), address(token), LIQUIDITY_0, LIQUIDITY_1, 0, 0, deployer, block.timestamp + 200
        );

        address pool = factory.getPair(address(weth), address(token));

        assertNotEq(pool, address(0), "pair has been created");

        assertEq(liquidity0, LIQUIDITY_0, "liquidity0 equals the desired amount");
        assertEq(liquidity1, LIQUIDITY_1, "liquidity1 equals the desired amount");

        assertEq(weth.balanceOf(pool), LIQUIDITY_0, "weth balance of pool equals the desired amount");
        assertEq(token.balanceOf(pool), LIQUIDITY_1, "token balance of pool equals the desired amount");
    }

    function test_unauthorizedCannotCreatePancakeSwapPool() external {
        deal(address(weth), chuck, LIQUIDITY_0);
        deal(address(token), chuck, LIQUIDITY_1);

        vm.startPrank(chuck);

        weth.approve(address(router), LIQUIDITY_0);
        token.approve(address(router), LIQUIDITY_1);

        vm.expectRevert();
        router.addLiquidity(address(weth), address(token), LIQUIDITY_0, LIQUIDITY_1, 0, 0, chuck, block.timestamp + 200);
    }
}
