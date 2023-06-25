// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../auth/FarmingBaseACL.sol";

contract ConvexFraxAuthorizer is FarmingBaseACL {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 public constant NAME = "ConvexFraxAuthorizer";
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) FarmingBaseACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = farmPoolAddressWhitelist.values();
    }

    // Checking functions.

    function deposit(uint256 _amount, address _to) external view {
        _checkRecipient(_to);
    }
}
