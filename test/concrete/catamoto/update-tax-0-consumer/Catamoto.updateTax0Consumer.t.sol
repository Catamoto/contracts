// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

import { Catamoto } from "src/Catamoto.sol";
import { Errors } from "src/libraries/Errors.sol";
import { ICatamotoTaxConsumer } from "src/ICatamotoTaxConsumer.sol";

import { CatamotoTest } from "test/CatamotoTest.sol";
import { Empty } from "test/samples/Empty.sol";
import { CatamotoTaxConsumerMock } from "test/mocks/CatamotoTaxConsumerMock.sol";

contract Catamoto_updateTax0Consumer is CatamotoTest {
    function setUp() public override {
        super.setUp();

        token = fixture();
    }

    function test_WhenTheCallerIsNotAuthorized() external {
        vm.startPrank(chuck);

        // it reverts
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, chuck, 0x00));
        token.updateSupervisedTransfersEndAt(0);
    }

    modifier whenTheCallerIsAuthorized() {
        vm.startPrank(deployer);
        _;
    }

    function test_WhenConsumerAddressIsZeroAddress() external whenTheCallerIsAuthorized {
        // it reverts
        vm.expectRevert(abi.encodeWithSelector(Errors.UnacceptableReference.selector, address(0)));
        token.updateTax0Consumer(ICatamotoTaxConsumer(address(0)));
    }

    function test_WhenConsumerAddressDoesNotExists() external whenTheCallerIsAuthorized {
        // it reverts
        vm.expectRevert(abi.encodeWithSelector(Errors.UnacceptableReference.selector, address(1)));
        token.updateTax0Consumer(ICatamotoTaxConsumer(address(1)));
    }

    function test_WhenConsumerDoesNotImplementRequiredInterface() external whenTheCallerIsAuthorized {
        Empty empty = new Empty();

        // it reverts
        vm.expectRevert(abi.encodeWithSelector(Errors.UnacceptableReference.selector, address(empty)));
        token.updateTax0Consumer(ICatamotoTaxConsumer(address(empty)));
    }

    function test_WhenConsumerAddressIsNonZeroAddress() external whenTheCallerIsAuthorized {
        CatamotoTaxConsumerMock consumer = new CatamotoTaxConsumerMock();

        // it emits event
        vm.expectEmit(false, false, false, true);
        emit Catamoto.UpdatedTax0Consumer(address(consumer));

        token.updateTax0Consumer(ICatamotoTaxConsumer(address(consumer)));

        assertEq(address(token.tax0Consumer()), address(consumer), "it updates the consumer address");
    }
}
