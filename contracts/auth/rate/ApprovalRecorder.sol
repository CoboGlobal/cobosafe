// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "./BaseRecorder.sol";

contract ApprovalRecorder is BaseRecorder {
    bytes32 public constant NAME = "ApprovalRecorder";
    uint256 public constant VERSION = 1;

    // function approve(address spender, uint256 value)
    bytes4 internal constant APPROVE_SELECTOR = 0x095ea7b3;

    constructor(address _owner, address _caller) BaseRecorder(_owner, _caller) {}

    function _decodeTransactionData(
        TransactionData calldata transaction
    ) internal pure override returns (address token, address spender, uint256 amount) {
        if (
            transaction.data.length >= 68 && // 4 + 32 + 32
            bytes4(transaction.data[0:4]) == APPROVE_SELECTOR &&
            transaction.value == 0
        ) {
            (spender, amount) = abi.decode(transaction.data[4:], (address, uint256));
            token = transaction.to;
        }
        return (token, spender, amount);
    }
}
