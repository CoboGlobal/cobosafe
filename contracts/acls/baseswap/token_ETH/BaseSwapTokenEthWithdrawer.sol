// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../BaseSwapWithdrawer.sol";

contract BaseSwapTokenEthWithdrawer is BaseSwapWithdrawer {
    bytes32 public constant NAME = "BaseSwapTokenEthWithdrawer"; // token + ETH
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) BaseSwapWithdrawer(_owner, _caller) {}

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external view nonPayable onlyRouter {
        _checkAllowPoolToken(token);
        _checkRecipient(to);
    }
}
