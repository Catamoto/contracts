// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { Withdrawable } from "src/utils/Withdrawable.sol";

import { ERC20Sample } from "test/samples/ERC20Sample.sol";
import { WithdrawableTest } from "test/WithdrawableTest.sol";

contract Withdrawable_withdrawToken is WithdrawableTest {
    ERC20Sample internal erc20 = new ERC20Sample();

    function setUp() public override {
        super.setUp();

        deal(address(erc20), address(withdrawable), 1 ether);
    }

    function test_WhenTheCallerIsNotAuthorized() external {
        uint256 amount = erc20.balanceOf(address(withdrawable));

        vm.prank(chuck);

        // it reverts
        vm.expectRevert();
        withdrawable.withdrawToken(chuck, erc20, amount);
    }

    modifier whenTheCallerIsAuthorized() {
        _;
    }

    function test_GivenRecipientIsZeroAddress() external whenTheCallerIsAuthorized {
        uint256 amount = erc20.balanceOf(address(withdrawable));

        // it reverts
        vm.expectRevert(Withdrawable.WithdrawToZeroAddress.selector);
        withdrawable.withdrawToken(address(0), erc20, amount);
    }

    function test_GivenRecipientIsNonZeroAddress(uint256 amount) external whenTheCallerIsAuthorized {
        vm.assume(amount < erc20.balanceOf(address(withdrawable)));

        uint256 balance = erc20.balanceOf(alice);

        withdrawable.withdrawToken(alice, erc20, amount);

        assertEq(erc20.balanceOf(alice), balance + amount, "it withdraws token");
    }
}
