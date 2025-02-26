// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../BaseSwapWithdrawer.sol";

contract BaseSwapTokensWithdrawer is BaseSwapWithdrawer {
    bytes32 public constant NAME = "BaseSwapTokensWithdrawer"; // tokenA + tokenB
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) BaseSwapWithdrawer(_owner, _caller) {}
}
