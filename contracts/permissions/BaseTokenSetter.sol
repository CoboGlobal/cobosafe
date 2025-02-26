// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../base/BaseOwnable.sol";

abstract contract BaseTokenSetter is BaseOwnable {
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet allowedTokens;

    //events
    event AddAllowedToken(address indexed token);
    event RemoveAllowedToken(address indexed token);

    //owner
    function addAllowedTokens(address[] memory _tokens) external virtual onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            _addAllowedToken(_tokens[i]);
        }
    }

    function removeAllowedTokens(address[] memory _tokens) external virtual onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            _removeAllowedToken(_tokens[i]);
        }
    }

    function hasAllowedToken(address _token) external view returns (bool) {
        return _hasAllowedToken(_token);
    }

    function getAllowedTokens() public view returns (address[] memory) {
        return allowedTokens.values();
    }

    // internal
    function _addAllowedToken(address _token) internal virtual {
        if (allowedTokens.add(_token)) {
            emit AddAllowedToken(_token);
        }
    }

    function _removeAllowedToken(address _token) internal virtual {
        if (allowedTokens.remove(_token)) {
            emit RemoveAllowedToken(_token);
        }
    }

    function _hasAllowedToken(address _token) internal view returns (bool) {
        return allowedTokens.contains(_token);
    }

    function _checkAllowedToken(address _token) internal view {
        require(_hasAllowedToken(_token), "Token not allowed");
    }
}
