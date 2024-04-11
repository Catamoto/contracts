// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IPancakeRouterV2 } from "src/IPancakeRouterV2.sol";

contract PancakeRouterV2Mock is IPancakeRouterV2 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external { }

    function addLiquidity(address, address, uint256, uint256, uint256, uint256, address, uint256)
        external
        returns (uint256 amountA, uint256 amountB, uint256 liquidity)
    { }
}
