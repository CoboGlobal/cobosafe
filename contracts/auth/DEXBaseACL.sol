// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../base/BaseSimpleACL.sol";

/// @title DEXBaseACL - ACL template for DEX.
/// @author Cobo Safe Dev Team https://www.cobo.com/
abstract contract DEXBaseACL is BaseSimpleACL {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet swapInTokenWhitelist;
    EnumerableSet.AddressSet swapOutTokenWhitelist;

    event SwapInTokenAdded(address indexed token);
    event SwapInTokenRemoved(address indexed token);
    event SwapOutTokenAdded(address indexed token);
    event SwapOutTokenRemoved(address indexed token);

    struct SwapInToken {
        address token;
        bool tokenStatus;
    }

    struct SwapOutToken {
        address token;
        bool tokenStatus;
    }

    constructor(address _owner, address _caller) BaseSimpleACL(_owner, _caller) {}

    function TYPE() external view virtual override returns (bytes32) {
        return AuthType.DEX;
    }

    // External set functions.

    function addSwapInTokens(address[] calldata _tokens) external virtual onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            _addSwapInToken(_tokens[i]);
        }
    }

    function removeSwapInTokens(address[] calldata _tokens) external virtual onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            _removeSwapInToken(_tokens[i]);
        }
    }

    function addSwapOutTokens(address[] calldata _tokens) external virtual onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            _addSwapOutToken(_tokens[i]);
        }
    }

    function removeSwapOutTokens(address[] calldata _tokens) external virtual onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            _removeSwapOutToken(_tokens[i]);
        }
    }

    // External view functions.
    function hasSwapInToken(address _token) public view returns (bool) {
        return swapInTokenWhitelist.contains(_token);
    }

    function getSwapInTokens() external view returns (address[] memory tokens) {
        return swapInTokenWhitelist.values();
    }

    function hasSwapOutToken(address _token) public view returns (bool) {
        return swapOutTokenWhitelist.contains(_token);
    }

    function getSwapOutTokens() external view returns (address[] memory tokens) {
        return swapOutTokenWhitelist.values();
    }

    // Internal check utility functions.

    function _swapInTokenCheck(address _token) internal view {
        require(hasSwapInToken(_token), "In token not allowed");
    }

    function _swapOutTokenCheck(address _token) internal view {
        require(hasSwapOutToken(_token), "Out token not allowed");
    }

    function _swapInOutTokenCheck(address _inToken, address _outToken) internal view {
        _swapInTokenCheck(_inToken);
        _swapOutTokenCheck(_outToken);
    }

    // Internal set functions.
    function _addSwapInToken(address _token) internal virtual {
        if (swapInTokenWhitelist.add(_token)) {
            emit SwapInTokenAdded(_token);
        }
    }

    function _removeSwapInToken(address _token) internal virtual {
        if (swapInTokenWhitelist.remove(_token)) {
            emit SwapInTokenRemoved(_token);
        }
    }

    function _addSwapOutToken(address _token) internal virtual {
        if (swapOutTokenWhitelist.add(_token)) {
            emit SwapOutTokenAdded(_token);
        }
    }

    function _removeSwapOutToken(address _token) internal virtual {
        if (swapOutTokenWhitelist.remove(_token)) {
            emit SwapOutTokenRemoved(_token);
        }
    }
}
