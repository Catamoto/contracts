// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { Test } from "test/Test.sol";
import { WithdrawableContract } from "test/samples/WithdrawableContract.sol";

contract WithdrawableTest is Test {
    WithdrawableContract withdrawable;

    function setUp() public virtual {
        withdrawable = new WithdrawableContract();
    }
}
