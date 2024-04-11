// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { CatamotoTest } from "test/CatamotoTest.sol";
import { CatamotoTaxConsumerMock } from "test/mocks/CatamotoTaxConsumerMock.sol";

contract Catamoto_taxed_transferFrom is CatamotoTest {
    function setUp() public override {
        super.setUp();

        token = fixture();

        deal(address(token), alice, 1 ether);
        deal(address(token), bob, 1 ether);
        deal(address(token), untaxed, 1 ether);
    }

    function test_WhenCallerIsUntaxed(uint256 amount) external {
        vm.assume(amount < token.balanceOf(alice));

        vm.prank(alice);
        token.approve(untaxed, 1 ether);

        uint256 balance = token.balanceOf(bob);

        vm.prank(untaxed);
        token.transferFrom(alice, bob, amount);

        assertEq(token.balanceOf(bob), balance + amount, "it transfers entire amount to the recipient");
    }

    function test_WhenSenderIsUntaxed(uint256 amount) external {
        vm.assume(amount < token.balanceOf(untaxed));

        vm.prank(untaxed);
        token.approve(alice, 1 ether);

        uint256 balance = token.balanceOf(bob);

        vm.prank(alice);
        token.transferFrom(untaxed, bob, amount);

        assertEq(token.balanceOf(bob), balance + amount, "it transfers entire amount to the recipient");
    }

    function test_WhenRecipientIsUntaxed(uint256 amount) external {
        vm.assume(amount < token.balanceOf(bob));

        vm.prank(bob);
        token.approve(alice, 1 ether);

        uint256 balance = token.balanceOf(untaxed);

        vm.prank(alice);
        token.transferFrom(bob, untaxed, amount);

        assertEq(token.balanceOf(untaxed), balance + amount, "it transfers entire amount to the recipient");
    }

    modifier whenCallerIsNotUntaxed() {
        _;
    }

    function test_WhenTax0ConsumerIsZeroAddress(uint256 amount) external whenCallerIsNotUntaxed {
        vm.assume(amount < token.balanceOf(bob));

        vm.startPrank(deployer);
        token.updateTax1Consumer(new CatamotoTaxConsumerMock());

        vm.startPrank(bob);
        token.approve(alice, 1 ether);

        uint256 balance = token.balanceOf(carol);

        vm.startPrank(alice);
        token.transferFrom(bob, carol, amount);

        uint256 tax = (amount * 5) / 1000;

        assertEq(token.balanceOf(address(token.tax1Consumer())), tax, "it transfers tax1 to the tax collector");
        assertEq(token.balanceOf(carol), balance + amount - tax, "it transfers reduced amount to the recipient");
    }

    function test_WhenTax0ConsumerIsNonZeroAddress(uint256 amount) external whenCallerIsNotUntaxed {
        vm.assume(amount < token.balanceOf(bob));

        vm.startPrank(deployer);
        token.updateTax0Consumer(new CatamotoTaxConsumerMock());
        token.updateTax1Consumer(new CatamotoTaxConsumerMock());

        vm.startPrank(bob);
        token.approve(alice, 1 ether);

        uint256 balance = token.balanceOf(carol);

        vm.startPrank(alice);
        token.transferFrom(bob, carol, amount);

        uint256 tax0 = (amount * 5) / 1000;
        uint256 tax1 = (amount * 5) / 1000;

        assertEq(token.balanceOf(address(token.tax0Consumer())), tax0, "it transfers tax0 to the tax collector");
        assertEq(token.balanceOf(address(token.tax1Consumer())), tax1, "it transfers tax1 to the tax collector");
        assertEq(token.balanceOf(carol), balance + amount - tax0 - tax1, "it transfers reduced amount to the recipient");
    }

    function test_WhenTax1ConsumerIsZeroAddress(uint256 amount) external whenCallerIsNotUntaxed {
        vm.assume(amount < token.balanceOf(bob));

        vm.startPrank(deployer);
        token.updateTax0Consumer(new CatamotoTaxConsumerMock());

        vm.startPrank(bob);
        token.approve(alice, 1 ether);

        uint256 balance = token.balanceOf(carol);

        vm.startPrank(alice);
        token.transferFrom(bob, carol, amount);

        uint256 tax = (amount * 5) / 1000;

        assertEq(token.balanceOf(address(token.tax0Consumer())), tax, "it transfers tax0 to the tax collector");
        assertEq(token.balanceOf(carol), balance + amount - tax, "it transfers reduced amount to the recipient");
    }

    function test_WhenTax1ConsumerIsNonZeroAddress(uint256 amount) external whenCallerIsNotUntaxed {
        vm.assume(amount < token.balanceOf(bob));

        vm.startPrank(deployer);
        token.updateTax0Consumer(new CatamotoTaxConsumerMock());
        token.updateTax1Consumer(new CatamotoTaxConsumerMock());

        vm.startPrank(bob);
        token.approve(alice, 1 ether);

        uint256 balance = token.balanceOf(carol);

        vm.startPrank(alice);
        token.transferFrom(bob, carol, amount);

        uint256 tax0 = (amount * 5) / 1000;
        uint256 tax1 = (amount * 5) / 1000;

        assertEq(token.balanceOf(address(token.tax0Consumer())), tax0, "it transfers tax0 to the tax collector");
        assertEq(token.balanceOf(address(token.tax1Consumer())), tax1, "it transfers tax1 to the tax collector");
        assertEq(token.balanceOf(carol), balance + amount - tax0 - tax1, "it transfers reduced amount to the recipient");
    }
}
