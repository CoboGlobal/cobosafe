# Hint

对于有些 Authorizer，进行权限检查的逻辑比较复杂，gas 消耗较高。Authorizer 开发者允许用户在交易中添加一些提示性的附加数据来加速检查过程，节约 gas。这些附加数据即为 `Hint`。

发起交易时可使用 `CallData` 结构体中的 `hint` 字段来传入这个 `Hint`。 
```solidity
struct CallData {
    uint256 flag; // 0x1 delegate call, 0x0 call.
    address to;
    uint256 value;
    bytes data; // calldata
    bytes hint;
    bytes extra; // for future support: signatures etc.
}
```

以 `ArgusRootAuthorizer` 为例。在 `ArgusRootAuthorizer` 中，`Delegate` 可以对应多个 `Role`，每个 `Role` 可以对应多个 `Authorizer`，只要其中有一个 `Authorizer` 检查通过，则整个交易就可以放行。

因此检查此交易时不需要遍历所有 `Authorizer`，因为大部分 `Authorizer` 检查都不能通过，只需要找到最终的可以使检查通过的 `Authorizer` 即可。因此在这种情况下， `Role` 和 `Authorizer` 就可以作为一种 `Hint`。

使用 `Hint` 进行交易的流程如下：
1. 可通过以 `eth_call` 的形式发起一次未设置 `hint` 的 `execTransaction()` 交易，返回的 `TransactionResult` 的 `hint` 即为本次交易的 `Hint`。
2. 在 `CallData` 中设置 `hint` 发起交易。
3. 在 `ArgusRootAuthorizer` 解码 `hint`，得到 `Role` 和 `Authorizer`。
4. 通过 `Role Manager` 检查 `hint` 中的 `Role` 和交易中的 `Delegate` 是否是匹配的。
5. 在 `ArgusRootAuthorizer` 检查 `Authorizer` 是否注册在这个 `Role` 中。
6. 4-5 任意检查失败，说明 `hint` 是无效的，直接拒绝交易。否则说明 `hint` 是真实的，使用 `hint` 中指定的 `Authorizer` 进行检查，如果通过，则放行交易。

目前 `ArgusRootAuthorizer` 在不设置 `hint` 的情况下仍可正常进行检查，只是 gas 消耗更高。

另外对于同时存在  `preExecCheck` 和 `postExecCheck` 的 `Authorizer`，`ArgusRootAuthorizer` 默认会传入相同的 `hint`。