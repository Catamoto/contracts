// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Errors } from "src/libraries/Errors.sol";

import { CatamotoTest } from "test/CatamotoTest.sol";

contract Catamoto_supervised_transfer is CatamotoTest {
    uint64 timestamp;

    function setUp() public override {
        super.setUp();

        token = fixture();

        deal(address(token), alice, 1 ether);
        deal(address(token), carol, 1 ether);

        vm.prank(deployer);
        token.grantRole(keccak256("ALLOWED_TO_TRANSFER_EARLY_ROLE"), alice);
    }

    function test_WhenSupervisedTransfersEndAtTimestampEqualsZero(uint256 amount) external {
        vm.assume(amount < token.balanceOf(carol));

        vm.prank(carol);

        // it transfers
        vm.expectEmit(true, true, false, false);
        emit IERC20.Transfer(carol, bob, 0);

        token.transfer(bob, amount);
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
        uint256 amount = token.balanceOf(carol) / 2;

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
        vm.assume(amount < token.balanceOf(alice));

        vm.prank(alice);

        // it transfers
        vm.expectEmit(true, true, false, false);
        emit IERC20.Transfer(alice, bob, 0);

        token.transfer(bob, amount);
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
        vm.assume(amount < token.balanceOf(carol));

        vm.prank(carol);

        // it transfers
        vm.expectEmit(true, true, false, false);
        emit IERC20.Transfer(carol, bob, 0);

        token.transfer(bob, amount);
    }

    function test_WhenCallerHasRoleThatGivesHimAuthority(uint256 amount)
        external
        whenSupervisedTransfersEndAtTimestampIsNonZero
        whenBlockTimestampIsEqualsOrAfterSupervisedTransfersEndAtTimestamp
    {
        vm.assume(amount < token.balanceOf(alice));

        vm.prank(alice);

        // it transfers
        vm.expectEmit(true, true, false, false);
        emit IERC20.Transfer(alice, bob, 0);

        token.transfer(bob, amount);
    }
}
