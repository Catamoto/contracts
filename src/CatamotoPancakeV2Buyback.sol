// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { Errors } from "src/libraries/Errors.sol";
import { IPancakeRouterV2 } from "src/IPancakeRouterV2.sol";
import { IPancakeFactoryV2 } from "src/IPancakeFactoryV2.sol";
import { ICatamotoTaxConsumer } from "src/ICatamotoTaxConsumer.sol";
import { CatamotoTaxConsumerPancakeV2 } from "src/CatamotoTaxConsumerPancakeV2.sol";

/**
 * @title CatamotoPancakeV2Buyback
 *
 * @notice An implementation of the buyback mechanism. The mechanism is to
 * perform `token0` to `token1` swap using PancakeSwap V2. The mechanism assumes
 * that `token0` and `token1` form a pair with `middleman` token. The swap is
 * not executed if one of the given addresses is exempt from execution or if the
 * balance of the `token0` equals zero.
 */
contract CatamotoPancakeV2Buyback is CatamotoTaxConsumerPancakeV2 {
    uint256 public constant MAX_ALLOWANCE = type(uint256).max;

    /// @notice Address of the ERC20 token used in the buyback mechanism.
    IERC20 public immutable middleman;

    /// @notice Contract state initialization.
    /// @param token0_ Address of the ERC20 token.
    /// @param middleman_ Address of the ERC20 token.
    /// @param token1_ Address of the ERC20 token.
    /// @param router_ Address of the Pancake router.
    /// @param factory_ Address of the Pancake factory.
    constructor(IERC20 token0_, IERC20 middleman_, IERC20 token1_, IPancakeRouterV2 router_, IPancakeFactoryV2 factory_)
        CatamotoTaxConsumerPancakeV2(token0_, token1_, router_, factory_)
    {
        if (address(middleman_) == address(0)) revert Errors.UnacceptableReference(address(0));

        middleman = middleman_;

        SafeERC20.forceApprove(token0, address(router), MAX_ALLOWANCE);
    }

    /// @inheritdoc ICatamotoTaxConsumer
    function execute(uint256, address sender, address from, address to)
        external
        override
        bypass(sender, from, to)
        onlyRole(EXECUTOR_ROLE)
    {
        address pair = factory.getPair(address(token0), address(middleman));

        if (sender == pair || pair == address(0)) return;

        uint256 amountIn = token0.balanceOf(address(this));

        if (amountIn == 0) return;

        if (token0.allowance(address(this), address(router)) < amountIn) {
            SafeERC20.forceApprove(token0, address(router), MAX_ALLOWANCE);
        }

        address[] memory swap = new address[](3);
        (swap[0], swap[1], swap[2]) = (address(token0), address(middleman), address(token1));

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, 0, swap, address(this), block.timestamp);

        emit Executed();
    }
}
