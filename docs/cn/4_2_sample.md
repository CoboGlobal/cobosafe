## Authorizer 示例

如下是一个简单的 Authorizer 示例，实现的访问控制逻辑是：
- 在交易发生前，检查交易中转账的 ETH 要小于 1000
- 在交易完成后，检查交易发起者（也就是钱包地址）的 ETH 余额要大于 10000

```solidity
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
        if(transaction.value < 1000){
            authData.result = AuthResult.SUCCESS;
        }else {
            authData.result = AuthResult.FAILED;
            authData.message = "Value over 1k not allowed";
        }
    }

    function _postExecCheck(
        TransactionData calldata transaction,
        TransactionResult calldata callResult,
        AuthorizerReturnData calldata preData
    ) internal override returns (AuthorizerReturnData memory authData) {
        if(transaction.from.balance > 10000){
            authData.result = AuthResult.SUCCESS;
        }else{
            authData.result = AuthResult.FAILED;
            authData.message = "Wallet balance dropped below 10k";
        }
    }
}
```

其他开发建议
- 如果 `BaseACL` 可以满足您的开发需求，请直接使用 `BaseACL`。如果不能，请阅读接下来的建议。
- 开发者只需实现 `IAuthorizer` 接口就能实现一个 Cobo Safe 框架可兼容的 Authorizer。但更推荐的方式是继承 `BaseAuthorizer`。 `BaseAuthorizer` 内实现了一些常用的内部方法，并且进行了调用方的检查，更加安全。
- `BaseAuthorizer` 的 `caller` 指调用 `Authorizer` 的合约，通常为上级 `Authorizer` 或者 `Cobo Account`。
- `BaseAuthorizer` 的 `owner` 为可以修改 `Authorizer` 配置的地址，通常为 `Cobo Account` 对应的 wallet 地址。在 Argus 中，这个地址通常为 Gnosis Safe 钱包的地址。
- 关于 `Check` 和 `Process`：
    - 在 `preExecCheck` `postExecCheck` 中建议只进行数据检查，不进行数据更新（如 storage 的写入）。
    - 在 `preExecProcess` `postExecProcess` 中建议只进行数据更新，不进行数据检查。
    - 4 个函数大多数时候不会都被使用到（大多数情况只使用 `preExecCheck`），可以通过设置 `flag` 来标识您开发的 `Authorizer` 正常工作流程中需要的接口，减少整体权限检查流程的复杂度，从而节约 gas。
    - `preExecCheck` `postExecCheck` 中最好不要使用 `revert` 来表示拒绝，推荐的方式是使用 `authData.result` 返回值权限验证的结果。
