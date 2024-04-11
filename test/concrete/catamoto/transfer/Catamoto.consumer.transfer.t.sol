// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { CatamotoRevertingTaxConsumerMock } from "test/mocks/CatamotoRevertingTaxConsumerMock.sol";

import { CatamotoTest } from "test/CatamotoTest.sol";

contract Catamoto_consumer_transfer is CatamotoTest {
    function setUp() public override {
        super.setUp();

        token = fixture();

        deal(address(token), alice, 1 ether);
    }

    function test_WhenTax0ConsumerRevertsDuringTransfer(uint256 amount) external {
        vm.assume(amount < token.balanceOf(alice));

        CatamotoRevertingTaxConsumerMock consumer = new CatamotoRevertingTaxConsumerMock();

        vm.prank(deployer);
        token.updateTax0Consumer(consumer);

        vm.prank(alice);

        // it transfers
        vm.expectEmit(true, true, false, false);
        emit IERC20.Transfer(alice, bob, 0);

        token.transfer(bob, amount);
    }

    function test_WhenTax1ConsumerRevertsDuringTransfer(uint256 amount) external {
        vm.assume(amount < token.balanceOf(alice));

        CatamotoRevertingTaxConsumerMock consumer = new CatamotoRevertingTaxConsumerMock();

        vm.prank(deployer);
        token.updateTax1Consumer(consumer);

        vm.prank(alice);

        // it transfers
        vm.expectEmit(true, true, false, false);
        emit IERC20.Transfer(alice, bob, 0);

        token.transfer(bob, amount);
    }
}
