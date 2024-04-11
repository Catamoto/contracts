// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { Withdrawable } from "src/utils/Withdrawable.sol";

contract WithdrawableContract is Ownable, Withdrawable {
    constructor() Ownable(_msgSender()) { }

    modifier protectedWithdrawal() override {
        _checkOwner();
        _;
    }
}
