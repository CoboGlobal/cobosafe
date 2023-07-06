# Authorizer

`Authorizer` is the core module in `Cobo Safe` that is used to implement access controls.

All transactions sent by `Delegates` via `execTransaction()` must be approved by the `Authorizer` before execution.

An `Authorizer` has to implement the following interfaces:

```solidity
interface IAuthorizer {
    function flag() external view returns (uint256 authFlags);

    function preExecCheck(TransactionData calldata transaction) external returns (AuthorizerReturnData memory authData);

    function postExecCheck(
        TransactionData calldata transaction,
        TransactionResult calldata callResult,
        AuthorizerReturnData calldata preAuthData
    ) external returns (AuthorizerReturnData memory authData);

    function preExecProcess(TransactionData calldata transaction) external;

    function postExecProcess(TransactionData calldata transaction, TransactionResult calldata callResult) external;
}
```

* **preExecCheck**: validate the transaction before it is executed (e.g., contract address, call method, parameters, ETH amount of the transaction)
* **postExecCheck**: validate the transaction and its outcomes after it has been executed (e.g., changes in wallet balance, leverage ratio in a DeFi protocol)
* **preExecProcess**: complete certain operations before the transaction is executed (e.g., recording the transaction amount)
* **postExecProcess**: complete certain operations after the transaction has been executed
* **flag**: the above four methods are not mandatory for an `Authorizer`; the `Authorizer` can indicate the specific functions that need to be executed by configuring `flag`

The following struct shows a transaction that is yet to be executed:

```solidity
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
```

* **from**: the `msg.sender` of the transaction (e.g. the `from` value for a `Cobo Safe Account` will be the contract address of Safe) 
* **delegate**: the `Delegate` who sent the transaction; `Authorizer` will use this value to review whether the transaction is authorized
* All other fields have the same definition as that for `CallData` 

`postExecCheck` has two additional parameters:

* `TransactionResult:` the status and output of a transaction after it has been executed
* `AuthorizerReturnData:`data returned by `preExecCheck`
