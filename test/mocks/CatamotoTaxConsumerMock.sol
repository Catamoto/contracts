// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import { ICatamotoTaxConsumer } from "src/ICatamotoTaxConsumer.sol";

contract CatamotoTaxConsumerMock is ICatamotoTaxConsumer, ERC165 {
    function execute(uint256 amount, address caller, address from, address to) external virtual {
        //
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(ICatamotoTaxConsumer).interfaceId || super.supportsInterface(interfaceId);
    }
}
