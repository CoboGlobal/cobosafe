// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "./BaseRateLimitAuthorizer.sol";

/// @title TransferRateLimitAuthorizer - Manages ERC20/ETH transfer permissons.
/// @author Cobo Safe Dev Team https://www.cobo.com/
/// @notice This checks token-receiver-allowance pairs , no amount is restricted.
contract TransferRateLimitAuthorizer is BaseRateLimitAuthorizer {
    bytes32 public constant NAME = "TransferRateLimitAuthorizer";
    uint256 public constant VERSION = 1;

    // function transfer(address recipient, uint256 amount)
    bytes4 constant TRANSFER_SELECTOR = 0xa9059cbb;

    constructor(address _owner, address _caller) BaseRateLimitAuthorizer(_owner, _caller) {}

    function _decodeTransactionData(
        TransactionData calldata transaction
    ) internal pure override returns (address token, address receiver, uint256 amount) {
        if (
            transaction.data.length >= 68 && // 4 + 32 + 32
            bytes4(transaction.data[0:4]) == TRANSFER_SELECTOR &&
            transaction.value == 0
        ) {
            (receiver, amount) = abi.decode(transaction.data[4:], (address, uint256));
            token = transaction.to;
        } else if (transaction.data.length == 0 && transaction.value > 0) {
            token = ETH;
            receiver = transaction.to;
            amount = transaction.value;
        }
        return (token, receiver, amount);
    }
}
