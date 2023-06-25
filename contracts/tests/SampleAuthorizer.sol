// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../base/BaseAuthorizer.sol";

contract SampleAuthorizer is BaseAuthorizer {
    bytes32 public constant NAME = "SampleAuthorizer";
    uint256 public constant VERSION = 1;
    uint256 public constant flag = AuthFlags.FULL_MODE;

    constructor(address _owner, address _caller) BaseAuthorizer(_owner, _caller) {}

    function _preExecCheck(
        TransactionData calldata transaction
    ) internal override returns (AuthorizerReturnData memory authData) {
        if (transaction.value < 1000) {
            authData.result = AuthResult.SUCCESS;
        } else {
            authData.result = AuthResult.FAILED;
            authData.message = "Value over 1k not allowed";
        }
    }

    function _postExecCheck(
        TransactionData calldata transaction,
        TransactionResult calldata callResult,
        AuthorizerReturnData calldata preData
    ) internal override returns (AuthorizerReturnData memory authData) {
        if (transaction.from.balance > 10000) {
            authData.result = AuthResult.SUCCESS;
        } else {
            authData.result = AuthResult.FAILED;
            authData.message = "Wallet balance dropped below 10k";
        }
    }
}
