// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

import { Vm } from "forge-std/Vm.sol";

import { CatamotoPancakeV2AutoLiquidityTest } from "test/CatamotoPancakeV2AutoLiquidityTest.sol";

contract CatamotoPancakeV2AutoLiquidity_execute is CatamotoPancakeV2AutoLiquidityTest {
    bytes32 internal constant ROLE = keccak256("EXECUTOR_ROLE");

    address executor = makeAddr("executor");

    function test_WhenCallerIsNotAuthorized() external {
        vm.prank(chuck);

        // it reverts
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, chuck, ROLE));
        consumer.execute(1 ether, bypassed, alice, bob);
    }

    modifier whenCallerIsAuthorized() {
        consumer.grantRole(ROLE, executor);

        vm.startPrank(executor);
        _;
    }

    function setUp() public {
        consumer = fixture();
    }

    function test_WhenSenderIsAuthorizedToBypassExecution() external whenCallerIsAuthorized {
        vm.recordLogs();

        // it skips
        consumer.execute(1 ether, bypassed, alice, bob);

        Vm.Log[] memory entries = vm.getRecordedLogs();

        assertEq(entries.length, 0);
    }

    modifier whenSenderIsNotAuthorizedToBypassExecution() {
        _;
    }

    function test_WhenToken0BalanceIsNotEnough()
        external
        whenCallerIsAuthorized
        whenSenderIsNotAuthorizedToBypassExecution
    {
        vm.recordLogs();

        // it skips
        consumer.execute(1 ether, alice, alice, bob);

        Vm.Log[] memory entries = vm.getRecordedLogs();

        assertEq(entries.length, 0);
    }
}
