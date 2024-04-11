// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Test } from "test/e2e/bnb/Test.sol";

interface Disperse {
    function disperseToken(IERC20 token, address[] memory recipients, uint256[] memory values) external;
}

contract DisperseDuringSupervisedTransfersPeriod is Test {
    address internal constant DISPERSE = 0xD152f549545093347A162Dce210e7293f1452150;

    function setUp() public override {
        super.setUp();

        deal(address(weth), deployer, LIQUIDITY_0);

        vm.startPrank(deployer);
        token.updateSupervisedTransfersEndAt(uint64(vm.unixTime()));
        token.grantRole(keccak256("ALLOWED_TO_TRANSFER_EARLY_ROLE"), deployer);

        token.grantRole(keccak256("UNTAXED_ROLE"), DISPERSE);
        token.grantRole(keccak256("ALLOWED_TO_TRANSFER_EARLY_ROLE"), DISPERSE);
    }

    function test_authorizedCanSendTokensViaDisperseWithoutCollectingTax() external {
        uint256[] memory amounts = new uint256[](3);
        address[] memory recipients = new address[](3);

        (recipients[0], amounts[0]) = (makeAddr("recipient0"), 1 ether);
        (recipients[1], amounts[1]) = (makeAddr("recipient1"), 2 ether);
        (recipients[2], amounts[2]) = (makeAddr("recipient2"), 3 ether);

        token.approve(DISPERSE, amounts[0] + amounts[1] + amounts[2]);

        Disperse(DISPERSE).disperseToken(token, recipients, amounts);

        assertEq(token.balanceOf(recipients[0]), amounts[0]);
        assertEq(token.balanceOf(recipients[1]), amounts[1]);
        assertEq(token.balanceOf(recipients[2]), amounts[2]);
    }
}
