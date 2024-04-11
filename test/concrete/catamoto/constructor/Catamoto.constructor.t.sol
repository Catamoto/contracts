// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { Catamoto } from "src/Catamoto.sol";

import { CatamotoTest } from "test/CatamotoTest.sol";

contract Catamoto_constructor is CatamotoTest {
    function test_GivenTokenHasBeenDeployed() external {
        uint256 supply = 10000000 * 10 ** 18;

        token = fixture("Catamoto", "CATA", supply);

        assertEq(token.name(), "Catamoto", "it deploys token with given name");
        assertEq(token.symbol(), "CATA", "it deploys token with given symbol");

        assertEq(token.totalSupply(), supply, "it deploys token with given initial supply");
        assertEq(token.balanceOf(deployer), supply, "deployer balance equals to initial supply");

        assertTrue(token.hasRole(0x00, deployer), "it grants default admin role to the sender");
    }
}
