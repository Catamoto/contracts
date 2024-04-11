// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { Test as ForgeTest } from "forge-std/Test.sol";

abstract contract Test is ForgeTest {
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal carol = makeAddr("carol");
    address internal chuck = makeAddr("chuck");
    address internal deployer = makeAddr("deployer");
}
