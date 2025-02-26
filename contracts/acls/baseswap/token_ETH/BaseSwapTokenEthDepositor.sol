// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../BaseSwapDepositor.sol";

contract BaseSwapTokenEthDepositor is BaseSwapDepositor {
    bytes32 public constant NAME = "BaseSwapTokenEthDepositor"; // token + ETH
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) BaseSwapDepositor(_owner, _caller) {}

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external view onlyRouter {
        _checkAllowPoolToken(token);
        _checkRecipient(to);
    }
}
