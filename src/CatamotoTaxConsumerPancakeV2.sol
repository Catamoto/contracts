// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import { Errors } from "src/libraries/Errors.sol";
import { Withdrawable } from "src/utils/Withdrawable.sol";
import { IPancakeRouterV2 } from "src/IPancakeRouterV2.sol";
import { IPancakeFactoryV2 } from "src/IPancakeFactoryV2.sol";
import { ICatamotoTaxConsumer } from "src/ICatamotoTaxConsumer.sol";

abstract contract CatamotoTaxConsumerPancakeV2 is ICatamotoTaxConsumer, ERC165, AccessControl, Withdrawable {
    bytes32 internal constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    bytes32 internal constant EXECUTION_BYPASS_ROLE = keccak256("EXECUTION_BYPASS_ROLE");

    /// @notice Address of the ERC20 token used in the tax consumption mechanism.
    IERC20 public immutable token0;

    /// @notice Address of the ERC20 token used in the tax consumption mechanism.
    IERC20 public immutable token1;

    /// @notice Address of the Pancake router.
    IPancakeRouterV2 public immutable router;

    /// @notice Address of the Pancake factory.
    IPancakeFactoryV2 public immutable factory;

    /// @notice Ensures that the accounts can be used in tax consumption mechanism.
    /// @param sender Address of the sender.
    /// @param from Address of the sender.
    /// @param to Address of the recipient.
    modifier bypass(address sender, address from, address to) {
        if (
            hasRole(EXECUTION_BYPASS_ROLE, sender) || hasRole(EXECUTION_BYPASS_ROLE, from)
                || hasRole(EXECUTION_BYPASS_ROLE, to)
        ) {
            return;
        }
        _;
    }

    /// @notice Ensures that the account is eligible for withdrawal.
    modifier protectedWithdrawal() override {
        if (!hasRole(DEFAULT_ADMIN_ROLE, _msgSender())) revert Errors.Unauthorized(_msgSender());
        _;
    }

    /// @notice Contract state initialization.
    /// @param token0_ Address of the ERC20 token.
    /// @param token1_ Address of the ERC20 token.
    /// @param router_ Address of the Pancake router.
    /// @param factory_ Address of the Pancake factory.
    constructor(IERC20 token0_, IERC20 token1_, IPancakeRouterV2 router_, IPancakeFactoryV2 factory_) {
        if (
            address(token0_) == address(0) || address(token1_) == address(0) || address(router_) == address(0)
                || address(factory_) == address(0)
        ) {
            revert Errors.UnacceptableReference(address(0));
        }

        token0 = token0_;
        token1 = token1_;
        router = router_;
        factory = factory_;

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /// @inheritdoc ICatamotoTaxConsumer
    function execute(uint256, address sender, address from, address to) external virtual;

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControl, ERC165, IERC165)
        returns (bool)
    {
        return interfaceId == type(ICatamotoTaxConsumer).interfaceId || super.supportsInterface(interfaceId);
    }
}
