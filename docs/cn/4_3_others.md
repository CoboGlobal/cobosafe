# 其他 Authorizer

`Cobo Safe` 中已经集成了几种常用的 `Authorizer`，有此类需求的用户不需要单独开发。

## FuncAuthorizer

`FuncAuthorizer` 是一类简单但实用的 `Authorizer`。其检查的内容为合约调用地址及方法。

假如 `Owner` 想授权给 `Delegate` 以太坊上 `USDT` 转账的权限。通过 `FuncAuthorizer` 可以如下配置：

1. 确认 `USDT` 的合约地址 `0xdAC17F958D2ee523a2206206994597C13D831ec7`
2. 确认转账动作使用的合约方法为 `transfer(address,uint256)`。注意这个方法需要规范化成[函数签名的形式](https://docs.soliditylang.org/en/v0.8.19/abi-spec.html#function-selector)。
3. 调用 `FuncAuthorizer` 的 `addContractFuncs()` 或 `addContractFuncsSig()` 绑定上述地址与方法。

需要注意的是，上述授权仅限制了合约地址与方法，而无法限制合约调用时的参数。比如上述操作不能限制  `USDT` 转账的收款人与转账金额。如果要对上述内容进行限制，则需要编写 ACL 来实现更细粒度的访问控制。

## TransferAuthorizer

转账是区块链中最常见的操作。`TransferAuthorizer` 允许用户通过 `addTokenReceivers` 方法设置 `币种` `收款人` 对。被授权的 `Delegate` 可以将授权的币种直接转账给收款人。

其中 `币种` 对于 `ERC20 Token` 即为 token 的地址。对于 ETH/BNB 等链原生币种则使用 `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE` 表示。

## ArgusRootAuthorizer

`ArgusRootAuthorizer` 是  Argus 平台上的默认 `Authorizer`。`ArgusRootAuthorizer` 本身并不进行具体的权限检查，而是维护了一系列`子 Authorizer`。

`ArgusRootAuthorizer` 也采用 [Role-Based Access Control](https://en.wikipedia.org/wiki/Role-based_access_control) 的理念。在 `ArgusRootAuthorizer` 中允许为 `Role` 配置一到多个 `Authorizer`。

当交易进入 `ArgusRootAuthorizer` 时，
1. 首先获取交易的 `delegate`，通过 `Role Manager` 查找 `delegate` 所对应的 `Role`。
2. 获取每个 `Role` 所绑定的 `子 Authorizer`。
3. 调用 `子 Authorizer` 进行检查，任意 `子 Authorizer` 检查通过，则可使交易放行。如果未发现绑定的 `子 Authorizer` 或全部 `子 Authorizer` 均未检查通过，则拒绝交易。

当 `子 Authorizer` 同时存在  `preExecCheck` 和 `postExecCheck` 时， 当且仅当两个函数均检查通过后才认为 `子 Authorizer` 放行交易。