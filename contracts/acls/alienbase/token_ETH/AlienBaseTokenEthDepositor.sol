// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../AlienBaseDepositor.sol";

contract AlienBaseTokenEthDepositor is AlienBaseDepositor {
    bytes32 public constant NAME = "AlienBaseTokenEthDepositor"; // token + ETH
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) AlienBaseDepositor(_owner, _caller) {}

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external view onlyRouter {
        _checkAllowPoolToken(token);
        _checkRecipient(to);
    }
}
