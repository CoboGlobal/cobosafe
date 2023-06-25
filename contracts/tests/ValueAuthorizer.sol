// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../base/BaseAuthorizer.sol";

contract ValuePreGT10PostGT1000 is BaseAuthorizer {
    bytes32 public constant NAME = "ValuePre10Post1000";
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
        if (transaction.value > 10) {
            authData.result = AuthResult.SUCCESS;
        }
        ++preCheckCounter;
    }

    function _postExecCheck(
        TransactionData calldata transaction,
        TransactionResult calldata callResult,
        AuthorizerReturnData calldata preData
    ) internal override returns (AuthorizerReturnData memory authData) {
        if (transaction.value > 1000) {
            authData.result = AuthResult.SUCCESS;
        }
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

contract ValuePreGT1000PostGT10 is BaseAuthorizer {
    bytes32 public constant NAME = "ValuePre10Post1000";
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
        if (transaction.value > 1000) {
            authData.result = AuthResult.SUCCESS;
        }
        ++preCheckCounter;
    }

    function _postExecCheck(
        TransactionData calldata transaction,
        TransactionResult calldata callResult,
        AuthorizerReturnData calldata preData
    ) internal override returns (AuthorizerReturnData memory authData) {
        if (transaction.value > 10) {
            authData.result = AuthResult.SUCCESS;
        }
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

contract ValuePrePureCheck is BaseAuthorizer {
    bytes32 public constant NAME = "ValuePrePureCheck";
    uint256 public constant VERSION = 1;
    uint256 public constant flag = AuthFlags.HAS_PRE_CHECK_MASK;

    uint256 public immutable maxValue;
    uint256 public immutable minValue;

    constructor(address _owner, address _caller, uint256 _maxValue, uint256 _minValue) BaseAuthorizer(_owner, _caller) {
        maxValue = _maxValue;
        minValue = _minValue;
    }

    function _preExecCheck(
        TransactionData calldata transaction
    ) internal override returns (AuthorizerReturnData memory authData) {
        if (transaction.value >= minValue && transaction.value <= maxValue) {
            authData.result = AuthResult.SUCCESS;
        } else {
            authData.result = AuthResult.FAILED;
            authData.message = "ValuePrePure: Value not in range";
        }
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
