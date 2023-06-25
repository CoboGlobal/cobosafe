// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CoboToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("CoboToken", "CT") {
        _mint(msg.sender, initialSupply);
    }
}
