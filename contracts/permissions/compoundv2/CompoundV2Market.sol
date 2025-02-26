// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../BasePermission.sol";
import "../BaseTokenSetter.sol";

contract CompoundV2Market is BasePermission, BaseTokenSetter {
    bytes32 public constant NAME = "CompoundV2Market";
    uint256 public constant VERSION = 1;

    address public constant UNITROLLER = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;

    constructor(address _owner, address _caller) BasePermission(_owner, _caller) {}

    function contracts() public pure override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = UNITROLLER;
    }

    function enterMarkets(address[] calldata cTokens) external view {
        for (uint i = 0; i < cTokens.length; ++i) {
            _checkAllowedToken(cTokens[i]);
        }
    }

    function exitMarket(address cToken) external view {
        _checkAllowedToken(cToken);
    }
}
