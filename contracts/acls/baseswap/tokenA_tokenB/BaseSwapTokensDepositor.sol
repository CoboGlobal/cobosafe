// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../BaseSwapDepositor.sol";

contract BaseSwapTokensDepositor is BaseSwapDepositor {
    bytes32 public constant NAME = "BaseSwapTokensDepositor"; // tokenA + tokenB
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) BaseSwapDepositor(_owner, _caller) {}

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external view nonPayable onlyRouter {
        _checkAllowPoolToken(tokenA);
        _checkAllowPoolToken(tokenB);
        _checkRecipient(to);
    }
}
