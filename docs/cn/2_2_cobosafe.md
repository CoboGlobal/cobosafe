## Cobo Safe Account

`Cobo Safe Account` (也称为 `Cobo Safe Module`) 使用 [Safe](https://safe.global/) （原 `Gnosis Safe` ）作为底层钱包。`Cobo Safe Account` 也是 `Cobo Argus` 平台所支持的默认账户类型。

`Safe` 是一种多重签名智能合约钱包，需要多个 `Owner` 的签名才能发起交易。通过 `Cobo Safe` 框架，`Owner` 可以将一些交易权限开发放 `Delegate` 。 授权完成后 `Delegate` 可通过 `Cobo Safe Account` 发起单签交易，不再需要繁琐的多重签名。

`Cobo Safe Account` 基于 [Gnosis Safe Module](https://docs.safe.global/learn/safe-core/safe-core-protocol/modules-1) 实现上了上述功能。这也是 `Cobo Safe Account` 常被称为 `Module` 的原因。

对于 `Cobo Safe Account`，其 `Account Address` 就是 `Safe` 的合约地址。

`Cobo Safe Account` 通过如下方式发起交易：

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

