# Authorizer

`Authorizer` 是 `Cobo Safe` 中进行访问控制的合约模块。所有通过 `execTransaction()` 发起的交易，都应该经过 `Cobo Account` 中注册的 `Authorizer` 的检查后才能继续执行。

具体来说，`Authorizer` 应该实现如下接口:
```
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

其中：
- **preExecCheck** 可在交易执行前对交易的内容进行权限检查，比如检查调用的目标合约地址、调用的合约方法、转账的金额等。
- **postExecCheck** 可以交易完成后进行权限检查，比如可以检查交易后余额的变动、检查借贷操作后的杠杆率等。
- **preExecProcess** 可以在交易前执行一些特定的处理动作，这个处理通常与交易检查无关，比如用来记录某笔交易转账的金额。
- **postExecProcess** 可以在交易后执行一些特定的处理动作。
- **flag** 上述 4 个方法不一定是同时存在的，可通过 flag 进行标识。

在上述方法中，使用如下结构体来表示待处理的交易
```
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
- **from** 表示交易的 `msg.sender`，比如 `Cobo Safe Account` 的交易这个值应该是 `Safe` 的地址。
- **delegate** 表示发起交易的 `Delegate`。`Authorizer` 会根据这个值来判断其具备的权限是否正确。
- 其它字段与 `CallData` 结构体保持一致。

另外 `postExecCheck` 会有额外的两个参数，`TransactionResult` 类型的参数表示交易的执行结果，`AuthorizerReturnData` 类型的参数表示 `preExecCheck` 的返回结果。这些机制可以使开发者编写更为全面且灵活的检查规则。

# Authorizer 示例

如下是一个简单的 Authorizer 示例，实现的访问控制逻辑是：
- 在交易发生前，检查交易中转账的 ETH 要小于 1000
- 在交易完成后，检查交易发起者（也就是钱包地址）的 ETH 余额要大于 10000

```js
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