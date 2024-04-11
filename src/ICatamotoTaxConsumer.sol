// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface ICatamotoTaxConsumer is IERC165 {
    /// @notice Event emitted when the mechanism has been executed.
    event Executed();

    /// @notice Execute action after receiving funds.
    /// @param amount Received amount.
    /// @param sender Address of the sender.
    /// @param from Address of the sender.
    /// @param to Address of the recipient.
    function execute(uint256 amount, address sender, address from, address to) external;
}
