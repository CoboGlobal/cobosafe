// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

enum AuthResult {
    FAILED,
    SUCCESS
}

struct AuthorizerReturnData {
    AuthResult result;
    string message;
    bytes data;
}

struct TransactionData {
    address from; // `msg.sender` who performs the transaction a.k.a wallet address.
    address delegate; // Delegate who calls executeTransactions().
    // Same as CallData
    uint256 flag; // 0x1 delegate call, 0x0 call.
    address to;
    uint256 value;
    bytes data; // calldata
    bytes hint;
    bytes extra;
}

interface ICoboSafeAccount {
    function authorizer() external view returns (address);

    function getAllDelegates() external view returns (address[] memory);
}

interface IAuthorizer {
    function preExecCheck(TransactionData calldata transaction) external returns (AuthorizerReturnData memory authData);
}

contract AuthorizedDelegatesGetter {
    address[] public tempDelegates;

    function getAuthorizedDelegates(
        address _cobosafe,
        TransactionData memory _transaction
    ) external returns (address[] memory _delegates) {
        delete tempDelegates;
        ICoboSafeAccount cobosafe = ICoboSafeAccount(_cobosafe);
        _delegates = cobosafe.getAllDelegates();

        IAuthorizer argusRoot = IAuthorizer(cobosafe.authorizer());

        for (uint256 i = 0; i < _delegates.length; ++i) {
            address _delegate = _delegates[i];
            _transaction.delegate = _delegate;
            try argusRoot.preExecCheck(_transaction) returns (AuthorizerReturnData memory authData) {
                if (authData.result == AuthResult.SUCCESS) {
                    tempDelegates.push(_delegate);
                }
            } catch {}
        }
        _delegates = tempDelegates;
    }
}
