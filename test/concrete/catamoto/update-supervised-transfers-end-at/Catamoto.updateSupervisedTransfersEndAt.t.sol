// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

import { Catamoto } from "src/Catamoto.sol";
import { Errors } from "src/libraries/Errors.sol";

import { CatamotoTest } from "test/CatamotoTest.sol";

contract Catamoto_updateSupervisedTransfersEndAt is CatamotoTest {
    uint64 timestamp;

    function setUp() public override {
        super.setUp();

        token = fixture();
    }

    function test_WhenCallerIsNotAuthorized() external {
        vm.startPrank(chuck);

        // it reverts
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, chuck, 0x00));
        token.updateSupervisedTransfersEndAt(0);
    }

    modifier whenCallerIsAuthorized() {
        vm.startPrank(deployer);
        _;
    }

    function test_WhenCurrentValueEqualsZero(uint64 value) external whenCallerIsAuthorized {
        vm.expectEmit(false, false, false, true);
        emit Catamoto.UpdatedSupervisedTransfersEndAt(value);

        token.updateSupervisedTransfersEndAt(value);

        assertEq(token.supervisedTransfersEndAt(), value, "it sets the new timestamp");
    }

    modifier whenCurrentValueIsNonZero() {
        token.updateSupervisedTransfersEndAt(timestamp = uint64(vm.unixTime()));
        _;
    }

    function test_WhenBlockTimestampIsBeforeOrEqualsCurrentValue(uint64 value)
        external
        whenCallerIsAuthorized
        whenCurrentValueIsNonZero
    {
        vm.warp(timestamp);

        vm.expectEmit(false, false, false, true);
        emit Catamoto.UpdatedSupervisedTransfersEndAt(value);

        token.updateSupervisedTransfersEndAt(value);

        assertEq(token.supervisedTransfersEndAt(), value, "it sets the new timestamp");
    }

    function test_WhenBlockTimestampIsAfterCurrentValue() external whenCallerIsAuthorized whenCurrentValueIsNonZero {
        vm.warp(timestamp + 1);

        // it reverts
        vm.expectRevert(Errors.Forbidden.selector);
        token.updateSupervisedTransfersEndAt(0);
    }
}
