// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { Catamoto } from "src/Catamoto.sol";

import { CatamotoDeployer } from "script/CatamotoDeployer.s.sol";

import { Test } from "test/Test.sol";

abstract contract CatamotoTest is Test {
    address internal untaxed = makeAddr("untaxed");
    address internal taxCollector = makeAddr("taxCollector");

    Catamoto internal token;

    CatamotoDeployer internal script;

    function setUp() public virtual {
        script = new CatamotoDeployer();

        vm.allowCheatcodes(address(script));
    }

    function fixture() public returns (Catamoto) {
        return fixture("Catamoto", "CATA", 100000 * 10 ** 18);
    }

    function fixture(string memory name, string memory symbol, uint256 initialSupply) public returns (Catamoto) {
        vm.startPrank(deployer);
        token = script.token(name, symbol, initialSupply);
        vm.stopPrank();

        vm.prank(deployer);
        token.grantRole(keccak256("UNTAXED_ROLE"), untaxed);

        return token;
    }
}
