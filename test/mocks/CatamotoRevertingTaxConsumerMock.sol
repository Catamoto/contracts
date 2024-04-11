// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { CatamotoTaxConsumerMock } from "test/mocks/CatamotoTaxConsumerMock.sol";

contract CatamotoRevertingTaxConsumerMock is CatamotoTaxConsumerMock {
    function execute(uint256, address, address, address) external pure override {
        revert();
    }
}
