// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ERC165Checker } from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import { Errors } from "src/libraries/Errors.sol";
import { Withdrawable } from "src/utils/Withdrawable.sol";
import { ICatamotoTaxConsumer } from "src/ICatamotoTaxConsumer.sol";

/**
 * @title Catamoto
 *
 * @notice An implementation of the ERC20 token in the Catamoto ecosystem.
 *
 * The implementation has the ability to turn on the period of supervised
 * transfers, during which only authorized addresses can transfer funds. The
 * smart contract administrator has the ability to change the duration of the
 * period, but only if the period is still running.
 *
 * Tax is charged during the transfer. Part of the tax is transferred to
 * external smart contracts called "TaxConsumer", that implements the
 * consumption mechanism. In addition, the smart contract has the ability to
 * mark the address as untaxed.
 */
contract Catamoto is ERC20, ERC20Burnable, ERC20Permit, AccessControl, Withdrawable {
    bytes32 internal constant UNTAXED_ROLE = keccak256("UNTAXED_ROLE");
    bytes32 internal constant ALLOWED_TO_TRANSFER_EARLY_ROLE = keccak256("ALLOWED_TO_TRANSFER_EARLY_ROLE");

    uint32 internal constant TRANSFER_TAX_0_NUMERATOR = 5;
    uint32 internal constant TRANSFER_TAX_1_NUMERATOR = 5;
    uint32 internal constant TRANSFER_TAX_DENOMINATOR = 1000;

    /// @notice Address to external smart contract with the tax consumption logic.
    ICatamotoTaxConsumer public tax0Consumer;

    /// @notice Address to external smart contract with the tax consumption logic.
    ICatamotoTaxConsumer public tax1Consumer;

    /// @notice Timestamp after which "public" transfers will be available.
    uint64 public supervisedTransfersEndAt;

    /// @notice Event emitted when the value of `tax0Consumer` has been updated.
    /// @param consumer The address of the smart contract.
    event UpdatedTax0Consumer(address consumer);

    /// @notice Event emitted when the value of `tax1Consumer` has been updated.
    /// @param consumer The address of the smart contract.
    event UpdatedTax1Consumer(address consumer);

    /// @notice Event emitted when the value of `supervisedTransfersEndAt` has been updated.
    /// @param timestamp The value of the new timestamp.
    event UpdatedSupervisedTransfersEndAt(uint64 timestamp);

    /// @notice Ensures that the account is eligible for withdrawal.
    modifier protectedWithdrawal() override {
        if (!hasRole(DEFAULT_ADMIN_ROLE, _msgSender())) revert Errors.Unauthorized(_msgSender());
        _;
    }

    /// @notice Contract state initialization.
    /// @param name_ The name of the token.
    /// @param symbol_ The symbol of the token.
    /// @param initialSupply The initial supply of the token.
    constructor(string memory name_, string memory symbol_, uint256 initialSupply)
        ERC20(name_, symbol_)
        ERC20Permit(name_)
    {
        _grantRole(UNTAXED_ROLE, _msgSender());
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _mint(_msgSender(), initialSupply);
    }

    /// @notice Updates the address of the `tax0` consumer.
    /// @param consumer The address of the smart contract.
    function updateTax0Consumer(ICatamotoTaxConsumer consumer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (address(consumer) == address(0)) revert Errors.UnacceptableReference(address(consumer));

        if (!ERC165Checker.supportsInterface(address(consumer), type(ICatamotoTaxConsumer).interfaceId)) {
            revert Errors.UnacceptableReference(address(consumer));
        }

        tax0Consumer = consumer;

        emit UpdatedTax0Consumer(address(consumer));
    }

    /// @notice Updates the address of the `tax0` consumer.
    /// @param consumer The address of the smart contract.
    function updateTax1Consumer(ICatamotoTaxConsumer consumer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (address(consumer) == address(0)) revert Errors.UnacceptableReference(address(consumer));

        if (!ERC165Checker.supportsInterface(address(consumer), type(ICatamotoTaxConsumer).interfaceId)) {
            revert Errors.UnacceptableReference(address(consumer));
        }

        tax1Consumer = consumer;

        emit UpdatedTax1Consumer(address(consumer));
    }

    /// @notice Updates the timestamp after which "public" transfers will be available.
    /// @param timestamp The value of the new timestamp.
    function updateSupervisedTransfersEndAt(uint64 timestamp) external onlyRole(DEFAULT_ADMIN_ROLE) {
        // The timestamp cannot be changed if the previous one has passed.
        if (supervisedTransfersEndAt != 0 && block.timestamp > supervisedTransfersEndAt) revert Errors.Forbidden();

        supervisedTransfersEndAt = timestamp;

        emit UpdatedSupervisedTransfersEndAt(timestamp);
    }

    /// @inheritdoc ERC20
    /// @notice Checks if the sender is authorized to make transfer during the period of supervised transfers.
    /// In addition, it calculates the tax by which the transferred amount should be reduced.
    function _update(address from, address to, uint256 amount) internal override {
        if (block.timestamp < supervisedTransfersEndAt) {
            bool whitelisted =
                hasRole(ALLOWED_TO_TRANSFER_EARLY_ROLE, _msgSender()) || hasRole(ALLOWED_TO_TRANSFER_EARLY_ROLE, from);

            if (!whitelisted) revert Errors.Forbidden();
        }

        (uint256 tax0, uint256 tax1, uint256 reminder) = _computeTax(_msgSender(), from, to, amount);

        if (tax0 > 0) {
            super._update(from, address(tax0Consumer), tax0);

            // Protection against denial of service.
            try tax0Consumer.execute(tax0, _msgSender(), from, to) { } catch { }
        }

        if (tax1 > 0) {
            super._update(from, address(tax1Consumer), tax1);

            // Protection against denial of service.
            try tax1Consumer.execute(tax1, _msgSender(), from, to) { } catch { }
        }

        super._update(from, to, reminder);
    }

    /// @notice Calculate the tax depending on the transfer parties.
    /// @param sender Address of the sender.
    /// @param from Address of the sender.
    /// @param to Address of the recipient.
    /// @param amount Amount of the tokens.
    /// @return tax0 The value of calculated tax.
    /// @return tax1 The value of calculated tax.
    /// @return remainder The amount reduced by calculated tax.
    function _computeTax(address sender, address from, address to, uint256 amount)
        internal
        view
        returns (uint256 tax0, uint256 tax1, uint256 remainder)
    {
        // Skip calculations when one of the addresses is untaxed.
        if (hasRole(UNTAXED_ROLE, sender) || hasRole(UNTAXED_ROLE, to) || hasRole(UNTAXED_ROLE, from)) {
            return (tax0, tax1, amount);
        }

        uint32 rate0 = address(tax0Consumer) == address(0) ? 0 : TRANSFER_TAX_0_NUMERATOR;
        uint32 rate1 = address(tax1Consumer) == address(0) ? 0 : TRANSFER_TAX_1_NUMERATOR;

        unchecked {
            tax0 = (amount * rate0) / TRANSFER_TAX_DENOMINATOR;
            tax1 = (amount * rate1) / TRANSFER_TAX_DENOMINATOR;

            remainder = amount - tax0 - tax1;
        }

        return (tax0, tax1, remainder);
    }
}
