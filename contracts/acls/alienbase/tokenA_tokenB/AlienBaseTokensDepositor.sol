// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../AlienBaseDepositor.sol";

contract AlienBaseTokensDepositor is AlienBaseDepositor {
    bytes32 public constant NAME = "AlienBaseTokensDepositor"; // tokenA + tokenB
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) AlienBaseDepositor(_owner, _caller) {}

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external view nonPayable onlyRouter {
        _checkAllowPoolToken(tokenA);
        _checkAllowPoolToken(tokenB);
        _checkRecipient(to);
    }
}
