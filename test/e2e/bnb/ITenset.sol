// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITenset is IERC20 {
    function owner() external returns (address);

    function setExcludedFee(address account, bool excluded) external;
}
