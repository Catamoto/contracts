// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

library Errors {
    /// @notice The operation is not allowed.
    error Forbidden();

    /// @notice The caller account is not authorized to perform an operation.
    /// @param account Address of the account.
    error Unauthorized(address account);

    /// @notice Given reference is unsupported.
    /// @param account Address of the reference.
    error UnacceptableReference(address account);
}
