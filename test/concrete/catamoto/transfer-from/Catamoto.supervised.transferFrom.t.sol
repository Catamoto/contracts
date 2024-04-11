// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Errors } from "src/libraries/Errors.sol";

import { CatamotoTest } from "test/CatamotoTest.sol";

contract Catamoto_supervised_transferFrom is CatamotoTest {
    uint64 timestamp;

    function setUp() public override {
        super.setUp();

        token = fixture();

        deal(address(token), bob, 1 ether);

        vm.prank(deployer);
        token.grantRole(keccak256("ALLOWED_TO_TRANSFER_EARLY_ROLE"), alice);

        vm.startPrank(bob);
        token.approve(alice, 1 ether);
        token.approve(carol, 1 ether);
        vm.stopPrank();
    }

    function test_WhenSupervisedTransfersEndAtTimestampEqualsZero(uint256 amount) external {
        vm.assume(amount < token.balanceOf(bob));

        vm.prank(carol);

        // it transfers
        vm.expectEmit(true, true, false, false);
        emit IERC20.Transfer(bob, carol, 0);

        token.transferFrom(bob, carol, amount);
    }

    modifier whenSupervisedTransfersEndAtTimestampIsNonZero() {
        vm.prank(deployer);
        token.updateSupervisedTransfersEndAt(timestamp = uint64(vm.unixTime()));
        _;
    }

    modifier whenBlockTimestampIsBeforeSupervisedTransfersEndAtTimestamp() {
        vm.warp(timestamp - 1);
        _;
    }

    function test_WhenCallerIsNotAuthorized()
        external
        whenSupervisedTransfersEndAtTimestampIsNonZero
        whenBlockTimestampIsBeforeSupervisedTransfersEndAtTimestamp
    {
        uint256 amount = token.balanceOf(bob) / 2;

        vm.prank(carol);

        // it reverts
        vm.expectRevert(Errors.Forbidden.selector);
        token.transfer(bob, amount);
    }

    function test_WhenCallerIsAuthorized(uint256 amount)
        external
        whenSupervisedTransfersEndAtTimestampIsNonZero
        whenBlockTimestampIsBeforeSupervisedTransfersEndAtTimestamp
    {
        vm.assume(amount < token.balanceOf(bob));

        vm.prank(alice);

        // it transfers
        vm.expectEmit(true, true, false, false);
        emit IERC20.Transfer(bob, alice, 0);

        token.transferFrom(bob, alice, amount);
    }

    function test_WhenSenderIsAuthorized(uint256 amount)
        external
        whenSupervisedTransfersEndAtTimestampIsNonZero
        whenBlockTimestampIsBeforeSupervisedTransfersEndAtTimestamp
    {
        vm.assume(amount < token.balanceOf(bob));

        vm.prank(deployer);
        token.grantRole(keccak256("ALLOWED_TO_TRANSFER_EARLY_ROLE"), bob);

        vm.prank(carol);

        // it transfers
        vm.expectEmit(true, true, false, false);
        emit IERC20.Transfer(bob, alice, 0);

        token.transferFrom(bob, alice, amount);
    }

    modifier whenBlockTimestampIsEqualsOrAfterSupervisedTransfersEndAtTimestamp() {
        vm.warp(timestamp);
        _;
    }

    function test_WhenCallerDoesNotHaveRoleThatGivesHimAuthority(uint256 amount)
        external
        whenSupervisedTransfersEndAtTimestampIsNonZero
        whenBlockTimestampIsEqualsOrAfterSupervisedTransfersEndAtTimestamp
    {
        vm.assume(amount < token.balanceOf(bob));

        vm.prank(carol);

        // it transfers
        vm.expectEmit(true, true, false, false);
        emit IERC20.Transfer(bob, carol, 0);

        token.transferFrom(bob, carol, amount);
    }

    function test_WhenCallerHasRoleThatGivesHimAuthority(uint256 amount)
        external
        whenSupervisedTransfersEndAtTimestampIsNonZero
        whenBlockTimestampIsEqualsOrAfterSupervisedTransfersEndAtTimestamp
    {
        vm.assume(amount < token.balanceOf(bob));

        vm.prank(alice);

        // it transfers
        vm.expectEmit(true, true, false, false);
        emit IERC20.Transfer(bob, alice, 0);

        token.transferFrom(bob, alice, amount);
    }
}
