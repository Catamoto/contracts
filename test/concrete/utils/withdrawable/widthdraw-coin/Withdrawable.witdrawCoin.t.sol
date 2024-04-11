// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { Withdrawable } from "src/utils/Withdrawable.sol";

import { WithdrawableTest } from "test/WithdrawableTest.sol";

contract Withdrawable_withdrawCoin is WithdrawableTest {
    uint256 internal amount = 1 ether;

    function setUp() public override {
        super.setUp();

        vm.deal(address(withdrawable), amount);
    }

    function test_WhenTheCallerIsNotAuthorized() external {
        vm.prank(chuck);

        // it reverts
        vm.expectRevert();
        withdrawable.withdrawCoin(payable(chuck));
    }

    modifier whenTheCallerIsAuthorized() {
        _;
    }

    function test_GivenRecipientIsZeroAddress() external whenTheCallerIsAuthorized {
        // it reverts
        vm.expectRevert(Withdrawable.WithdrawToZeroAddress.selector);
        withdrawable.withdrawCoin(payable(address(0)));
    }

    function test_GivenRecipientIsNonZeroAddress() external whenTheCallerIsAuthorized {
        uint256 balance = alice.balance;

        withdrawable.withdrawCoin(payable(alice));

        assertEq(alice.balance, balance + amount, "it withdraws coin");
    }
}
