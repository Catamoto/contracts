// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IPancakeFactoryV2 } from "src/IPancakeFactoryV2.sol";

contract PancakeFactoryV2Mock is IPancakeFactoryV2 {
    function getPair(address, address) external pure returns (address pair) {
        return pair;
    }
}
