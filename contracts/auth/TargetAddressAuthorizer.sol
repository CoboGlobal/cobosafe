// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../base/BaseSimpleAuthorizer.sol";

/// @title TargetAddressAuthorizer - Manages available target addresses for delegates.
/// @author Cobo Safe Dev Team https://www.cobo.com/
/// @notice TargetAddressAuthorizer only checks `to` of the transaction, `value` and
///         `calldata` is skipped here.
contract TargetAddressAuthorizer is BaseSimpleAuthorizer {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 public constant NAME = "TargetAddressAuthorizer";
    uint256 public constant VERSION = 1;
    bytes32 public constant override TYPE = AuthType.ADDRESS;

    EnumerableSet.AddressSet targetAddresses;

    /// Events
    event TargetAddressAdded(address indexed _target);
    event TargetAddressRemoved(address indexed _target);

    constructor(address _owner, address _caller) BaseSimpleAuthorizer(_owner, _caller) {}

    function _preExecCheck(
        TransactionData calldata transaction
    ) internal view override returns (AuthorizerReturnData memory authData) {
        if (isTargetAddressAllowed(transaction.to)) {
            authData.result = AuthResult.SUCCESS;
        } else {
            authData.result = AuthResult.FAILED;
            authData.message = "Target address not allowed";
        }
    }

    /// Owner functions.

    function addTargetAddresses(address[] calldata _addresses) external onlyOwner {
        for (uint i = 0; i < _addresses.length; ++i) {
            address _target = _addresses[i];
            if (targetAddresses.add(_target)) {
                emit TargetAddressAdded(_target);
            }
        }
    }

    function removeTargetAddresses(address[] calldata _addresses) external onlyOwner {
        for (uint i = 0; i < _addresses.length; ++i) {
            address _target = _addresses[i];
            if (targetAddresses.remove(_target)) {
                emit TargetAddressRemoved(_target);
            }
        }
    }

    /// View functions.

    /// @notice Get all the allowed target addresses.
    function getTargetAddresses() external view returns (address[] memory) {
        return targetAddresses.values();
    }

    /// @notice Get the allowed target addresses by range.
    function getTargetAddresses(uint256 start, uint256 end) external view returns (address[] memory _addresses) {
        uint256 size = targetAddresses.length();
        if (end > size) end = size;
        require(start < end, "start >= end");

        _addresses = new address[](end - start);
        for (uint i = 0; i < end - start; i++) {
            _addresses[i] = targetAddresses.at(start + i);
        }
        return _addresses;
    }

    function isTargetAddressAllowed(address _target) public view returns (bool) {
        return targetAddresses.contains(_target);
    }
}
