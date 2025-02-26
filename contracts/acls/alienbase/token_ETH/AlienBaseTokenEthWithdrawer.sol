// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../AlienBaseWithdrawer.sol";

contract AlienBaseTokenEthWithdrawer is AlienBaseWithdrawer {
    bytes32 public constant NAME = "AlienBaseTokenEthWithdrawer"; // token + ETH
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) AlienBaseWithdrawer(_owner, _caller) {}

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external view nonPayable onlyRouter {
        _checkAllowPoolToken(token);
        _checkRecipient(to);
    }
}
