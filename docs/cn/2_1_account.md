# Cobo Account

`Cobo Account` 是 `Cobo Safe` 框架下抽象的一种智能合约钱包账户。`Cobo Account` 合约应该实现 `execTransaction()` 方法，如下：

```solidity
struct CallData {
    uint256 flag; // 0x1 delegate call, 0x0 call.
    address to;
    uint256 value;
    bytes data; // calldata
    bytes hint;
    bytes extra; // for future support: signatures etc.
}

struct TransactionResult {
    bool success; // Call status.
    bytes data; // Return/Revert data.
    bytes hint;
}

interface IAccount {
    function execTransaction(CallData calldata callData) external returns (TransactionResult memory result);

    function execTransactions(
        CallData[] calldata callDataList
    ) external returns (TransactionResult[] memory resultList);

    function getAccountAddress() external view returns (address account);
}
```

`Delegate` 可调用 `execTransaction()` 通过钱包发起交易，在 `execTransaction()` 内部，会使用 `Authorizer` 用来检查 `Delegate` 是否具备执行该交易的权限。

根据底层使用的智能合约钱包不同，`Cobo Account` 可以派生出不同的子类合约，`getAccountAddress()` 返回 `Cobo Account` 底层真正钱包的地址。

