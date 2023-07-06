## Cobo Safe Account

`Cobo Safe Account` uses [Safe](https://safe.global/)  (previously `Gnosis Safe`)as the underlying smart contract wallet. It is a multi-sig wallet where each transaction will require signatures from multiple Safe `Owners` for approval. `Cobo Safe Account` is the default account supported on `Cobo Argus`.

By leveraging the `Cobo Safe` framework, Safe `Owners` can delegate DeFi permissions to `Delegates.`The `Delegates` can then initiate transactions in the `Cobo Safe Account` and complete their authorized operations using **a single signature**.

`Cobo Safe Account` is built on top of the [Gnosis Safe Module](https://docs.safe.global/learn/safe-core/safe-core-protocol/modules-1). As such, the `Cobo Safe Account` is also referred to as the `Cobo Safe Module`.

The `Account Address` of a `Cobo Safe Account` is the underlying contract address of `Safe`.

`Cobo Safe Account` sends transactions with `execTransactionFromModuleReturnData` as follows: &#x20;

```solidity
contract CoboSafeAccount is BaseAccount {

    /// @dev Execute the transaction from the Safe.
    function _executeTransaction(
        TransactionData memory transaction
    ) internal override returns (TransactionResult memory result) {
        // execute the transaction from Gnosis Safe, note this call will bypass
        // Safe owners confirmation.
        (result.success, result.data) = IGnosisSafe(payable(safe())).execTransactionFromModuleReturnData(
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.flag.isDelegateCall() ? Enum.Operation.DelegateCall : Enum.Operation.Call
        );
    }

    /// @dev The account address is the Safe address.
    function _getAccountAddress() internal view override returns (address account) {
        account = safe();
    }
}
```
