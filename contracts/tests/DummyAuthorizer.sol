// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../base/BaseAuthorizer.sol";

/// @title A DummyAuthorizer which approves everything.
/// @author Cobo Safe Dev Team https://www.cobo.com/
/// @notice Mostly for test purpose and should not be used for security.
/// @dev For test: install this as default auth to make your wallet account useable.
contract DummyAuthorizer is BaseAuthorizer {
    bytes32 public constant NAME = "DummyAuthorizer";
    uint256 public constant VERSION = 1;
    uint256 public constant flag = AuthFlags.FULL_MODE;

    constructor(address _owner, address _caller) BaseAuthorizer(_owner, _caller) {}

    function _preExecCheck(
        TransactionData calldata transaction
    ) internal override returns (AuthorizerReturnData memory authData) {
        authData.result = AuthResult.SUCCESS;
    }

    function _postExecCheck(
        TransactionData calldata transaction,
        TransactionResult calldata callResult,
        AuthorizerReturnData calldata preData
    ) internal override returns (AuthorizerReturnData memory authData) {
        authData.result = AuthResult.SUCCESS;
    }

    function _preExecProcess(TransactionData calldata transaction) internal override {}

    function _postExecProcess(
        TransactionData calldata transaction,
        TransactionResult calldata callResult
    ) internal override {}
}

contract DummyCounterAuthorizer is BaseAuthorizer {
    bytes32 public constant NAME = "DummyCounterAuthorizer";
    uint256 public constant VERSION = 1;
    uint256 public constant flag = AuthFlags.FULL_MODE;

    uint256 public preCheckCounter = 0;
    uint256 public postCheckCounter = 0;
    uint256 public preProcessCounter = 0;
    uint256 public postProcessCounter = 0;

    constructor(address _owner, address _caller) BaseAuthorizer(_owner, _caller) {}

    function _preExecCheck(
        TransactionData calldata transaction
    ) internal override returns (AuthorizerReturnData memory authData) {
        authData.result = AuthResult.SUCCESS;
        ++preCheckCounter;
    }

    function _postExecCheck(
        TransactionData calldata transaction,
        TransactionResult calldata callResult,
        AuthorizerReturnData calldata preData
    ) internal override returns (AuthorizerReturnData memory authData) {
        authData.result = AuthResult.SUCCESS;
        ++postCheckCounter;
    }

    function _preExecProcess(TransactionData calldata transaction) internal override {
        ++preProcessCounter;
    }

    function _postExecProcess(
        TransactionData calldata transaction,
        TransactionResult calldata callResult
    ) internal override {
        ++postProcessCounter;
    }

    function reset() external {
        preCheckCounter = 0;
        postCheckCounter = 0;
        preProcessCounter = 0;
        postProcessCounter = 0;
    }
}
