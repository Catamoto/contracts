// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "forge-std/Script.sol";
import { VmSafe } from "forge-std/Vm.sol";

import { Catamoto } from "src/Catamoto.sol";

contract CatamotoDeployer is Script {
    Catamoto internal catamoto;

    modifier callerInterceptor() {
        (VmSafe.CallerMode mode, address caller,) = vm.readCallers();

        bool pranked = mode == VmSafe.CallerMode.Prank || mode == VmSafe.CallerMode.RecurrentPrank;

        if (pranked) vm.startPrank(caller);

        _;
    }

    function token(string memory name, string memory symbol, uint256 initialSupply)
        public
        callerInterceptor
        returns (Catamoto)
    {
        return catamoto = new Catamoto(name, symbol, initialSupply);
    }
}
