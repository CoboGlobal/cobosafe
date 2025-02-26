// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../AlienBaseWithdrawer.sol";

contract AlienBaseTokensWithdrawer is AlienBaseWithdrawer {
    bytes32 public constant NAME = "AlienBaseTokensWithdrawer"; // tokenA + tokenB
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) AlienBaseWithdrawer(_owner, _caller) {}
}
