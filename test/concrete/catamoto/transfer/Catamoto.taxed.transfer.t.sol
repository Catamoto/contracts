// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { CatamotoTest } from "test/CatamotoTest.sol";
import { CatamotoTaxConsumerMock } from "test/mocks/CatamotoTaxConsumerMock.sol";

contract Catamoto_taxed_transfer is CatamotoTest {
    function setUp() public override {
        super.setUp();

        token = fixture();

        deal(address(token), alice, 1 ether);
        deal(address(token), bob, 1 ether);
        deal(address(token), untaxed, 1 ether);
    }

    function test_WhenCallerIsUntaxed(uint256 amount) external {
        vm.assume(amount < token.balanceOf(untaxed));

        uint256 balance = token.balanceOf(alice);

        vm.prank(untaxed);

        token.transfer(alice, amount);

        assertEq(token.balanceOf(alice), balance + amount, "it transfers entire amount to the recipient");
    }

    function test_WhenRecipientIsUntaxed(uint256 amount) external {
        vm.assume(amount < token.balanceOf(alice));

        uint256 balance = token.balanceOf(untaxed);

        vm.prank(alice);

        token.transfer(untaxed, amount);

        assertEq(token.balanceOf(untaxed), balance + amount, "it transfers entire amount to the recipient");
    }

    modifier whenCallerIsNotUntaxed() {
        _;
    }

    function test_WhenTax0ConsumerIsZeroAddress(uint256 amount) external whenCallerIsNotUntaxed {
        vm.assume(amount > 0 / 2 && amount < token.balanceOf(bob));

        vm.startPrank(deployer);
        token.updateTax1Consumer(new CatamotoTaxConsumerMock());

        uint256 balance = token.balanceOf(alice);

        vm.startPrank(bob);

        token.transfer(alice, amount);

        uint256 tax = (amount * 5) / 1000;

        assertEq(token.balanceOf(address(token.tax1Consumer())), tax, "it transfers tax1 to the tax consumer");
        assertEq(token.balanceOf(alice), balance + amount - tax, "it transfers reduced amount to the recipient");
    }

    function test_WhenTax0ConsumerIsNonZeroAddress(uint256 amount) external whenCallerIsNotUntaxed {
        vm.assume(amount > 0 / 2 && amount < token.balanceOf(bob));

        vm.startPrank(deployer);
        token.updateTax0Consumer(new CatamotoTaxConsumerMock());
        token.updateTax1Consumer(new CatamotoTaxConsumerMock());

        uint256 balance = token.balanceOf(alice);

        vm.startPrank(bob);

        token.transfer(alice, amount);

        uint256 tax0 = (amount * 5) / 1000;
        uint256 tax1 = (amount * 5) / 1000;

        assertEq(token.balanceOf(address(token.tax0Consumer())), tax0, "it transfers tax0 to the tax consumer");
        assertEq(token.balanceOf(address(token.tax1Consumer())), tax1, "it transfers tax1 to the tax consumer");
        assertEq(token.balanceOf(alice), balance + amount - tax0 - tax1, "it transfers reduced amount to the recipient");
    }

    function test_WhenTax1ConsumerIsZeroAddress(uint256 amount) external whenCallerIsNotUntaxed {
        vm.assume(amount > 0 / 2 && amount < token.balanceOf(bob));

        vm.startPrank(deployer);
        token.updateTax0Consumer(new CatamotoTaxConsumerMock());

        uint256 balance = token.balanceOf(alice);

        vm.startPrank(bob);

        token.transfer(alice, amount);

        uint256 tax = (amount * 5) / 1000;

        assertEq(token.balanceOf(address(token.tax0Consumer())), tax, "it transfers tax0 to the tax consumer");
        assertEq(token.balanceOf(alice), balance + amount - tax, "it transfers reduced amount to the recipient");
    }

    function test_WhenTax1ConsumerIsNonZeroAddress(uint256 amount) external whenCallerIsNotUntaxed {
        vm.assume(amount > 0 / 2 && amount < token.balanceOf(bob));

        vm.startPrank(deployer);
        token.updateTax0Consumer(new CatamotoTaxConsumerMock());
        token.updateTax1Consumer(new CatamotoTaxConsumerMock());

        uint256 balance = token.balanceOf(alice);

        vm.startPrank(bob);

        token.transfer(alice, amount);

        uint256 tax0 = (amount * 5) / 1000;
        uint256 tax1 = (amount * 5) / 1000;

        assertEq(token.balanceOf(address(token.tax0Consumer())), tax0, "it transfers tax0 to the tax consumer");
        assertEq(token.balanceOf(address(token.tax1Consumer())), tax1, "it transfers tax1 to the tax consumer");
        assertEq(token.balanceOf(alice), balance + amount - tax0 - tax1, "it transfers reduced amount to the recipient");
    }
}
