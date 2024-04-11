// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { IPancakeRouterV2 } from "src/IPancakeRouterV2.sol";
import { IPancakeFactoryV2 } from "src/IPancakeFactoryV2.sol";
import { ICatamotoTaxConsumer } from "src/ICatamotoTaxConsumer.sol";
import { CatamotoTaxConsumerPancakeV2 } from "src/CatamotoTaxConsumerPancakeV2.sol";

/**
 * @title CatamotoPancakeV2AutoLiquidity
 *
 * @notice An implementation of the auto liquidity to the Uniswap V2 pair. The
 * mechanism assumes that `token0` and `token1` creates the pair. The mechanism
 * is not executed if one of the given addresses is exempt from execution.
 */
contract CatamotoPancakeV2AutoLiquidity is CatamotoTaxConsumerPancakeV2 {
    uint256 public constant MAX_ALLOWANCE = type(uint256).max;

    /// @notice Contract state initialization.
    /// @param token0_ Address of the ERC20 token.
    /// @param token1_ Address of the ERC20 token.
    /// @param router_ Address of the Pancake router.
    /// @param factory_ Address of the Pancake factory.
    constructor(IERC20 token0_, IERC20 token1_, IPancakeRouterV2 router_, IPancakeFactoryV2 factory_)
        CatamotoTaxConsumerPancakeV2(token0_, token1_, router_, factory_)
    {
        SafeERC20.forceApprove(token0, address(router), MAX_ALLOWANCE);
        SafeERC20.forceApprove(token1, address(router), MAX_ALLOWANCE);
    }

    /// @inheritdoc ICatamotoTaxConsumer
    function execute(uint256, address sender, address from, address to)
        external
        override
        bypass(sender, from, to)
        onlyRole(EXECUTOR_ROLE)
    {
        address pair = factory.getPair(address(token0), address(token1));

        if (sender == pair || pair == address(0)) return;

        uint256 amount0 = token0.balanceOf(address(this));

        if (amount0 < 2) return;

        uint256 amountIn0;

        unchecked {
            amountIn0 = amount0 / 2;
        }

        if (token0.allowance(address(this), address(router)) < amount0) {
            SafeERC20.forceApprove(token0, address(router), MAX_ALLOWANCE);
        }

        address[] memory swap = new address[](2);
        (swap[0], swap[1]) = (address(token0), address(token1));

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn0, 0, swap, address(this), block.timestamp);

        uint256 amountIn1 = token1.balanceOf(address(this));

        if (amountIn1 == 0) return;

        if (token1.allowance(address(this), address(router)) < amountIn1) {
            SafeERC20.forceApprove(token1, address(router), MAX_ALLOWANCE);
        }

        router.addLiquidity(
            address(token0), address(token1), amountIn0, amountIn1, 0, 0, address(this), block.timestamp
        );

        emit Executed();
    }
}
