// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Withdrawable
 *
 * @notice This contract allows for withdrawing tokens and native Ether from the contract.
 * It also provides a method to receive Ether into the contract.
 */
abstract contract Withdrawable {
    using SafeERC20 for IERC20;

    /// @notice Reference address is `address(0)`.
    error WithdrawToZeroAddress();

    /// @notice Ensures the caller is eligible to withdraw.
    modifier protectedWithdrawal() virtual;

    receive() external payable virtual { }

    /// @notice Withdraws the token to the recipient.
    /// @param to Address of the recipient.
    /// @param token_ Address of the token.
    /// @param amount Amount to withdraw.
    function withdrawToken(address to, IERC20 token_, uint256 amount) public virtual protectedWithdrawal {
        if (to == address(0)) revert WithdrawToZeroAddress();

        token_.safeTransfer(to, amount);
    }

    /// @notice Withdraws the native coin to the recipient.
    /// @param to Address of the recipient.
    function withdrawCoin(address payable to) public virtual protectedWithdrawal {
        if (to == address(0)) revert WithdrawToZeroAddress();

        to.transfer(address(this).balance);
    }
}
