// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "./base/BaseAccount.sol";

/// @title CoboSmartAccount - A simple smart contract wallet that implements customized access control
/// @author Cobo Safe Dev Team https://www.cobo.com/
contract CoboSmartAccount is BaseAccount {
    using TxFlags for uint256;

    bytes32 public constant NAME = "CoboSmartAccount";
    uint256 public constant VERSION = 2;

    constructor(address _owner) BaseAccount(_owner) {
        _addDelegate(_owner); // Add owner as a delegate.
    }

    /// @dev Perform a call directly from the contract itself.
    function _executeTransaction(
        TransactionData memory transaction
    ) internal override returns (TransactionResult memory result) {
        address to = transaction.to;
        uint256 value = transaction.value;
        bytes memory data = transaction.data;
        if (transaction.flag.isDelegateCall()) {
            // Ignore value here as we are doing delegatecall.
            (result.success, result.data) = address(to).delegatecall(data);
        } else {
            (result.success, result.data) = address(to).call{value: value}(data);
        }
    }

    /// @dev The contract itself.
    function _getAccountAddress() internal view override returns (address account) {
        return (address(this));
    }

    function _executeTransactionWithCheck(
        TransactionData memory transaction
    ) internal override returns (TransactionResult memory result) {
        // Skip check and process for the owner
        if (msg.sender == owner) {
            return _executeTransaction(transaction);
        }

        return super._executeTransactionWithCheck(transaction);
    }
}
