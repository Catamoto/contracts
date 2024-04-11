// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

interface IPancakeFactoryV2 {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
