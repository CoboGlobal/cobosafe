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


## Cobo Safe Account

`Cobo Safe Account` (也称为 `Cobo Safe Module`) 使用 [Safe](https://safe.global/) （原 `Gnosis Safe` ）作为底层钱包。`Cobo Safe Account` 也是 `Cobo Argus` 平台所支持的默认账户类型。

`Safe` 是一种多重签名智能合约钱包，需要多个 `Owner` 的签名才能发起交易。通过 `Cobo Safe` 框架，`Owner` 可以将一些交易权限开发放 `Delegate` 。 授权完成后 `Delegate` 可通过 `Cobo Safe Account` 发起单签交易，不再需要繁琐的多重签名。

`Cobo Safe Account` 基于 [Gnosis Safe Module](https://docs.safe.global/learn/safe-core/safe-core-protocol/modules-1) 实现上了上述功能。这也是 `Cobo Safe Account` 常被称为 `Module` 的原因。

对于 `Cobo Safe Account`，其 `Account Address` 就是 `Safe` 的合约地址。

`Cobo Safe Account` 通过如下方式发起交易：
```
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



## Cobo Smart Account

`Cobo Smart Account` 一个简单的智能合约钱包，钱包的资产保存在 `Cobo Smart Account` 本身的智能合约中。其 `Account Address` 就是合约自身。`Cobo Smart Account` 可直接通过 `call` 和 `delegatecall` 发起交易。

如下：
```
contract CoboSmartAccount is BaseAccount {
    /// @dev Perform a call directly from the contract itself.
    function _executeTransaction(
        TransactionData memory transaction
    ) internal override returns (TransactionResult memory result) {
        address to = transaction.to;
        uint256 value = transaction.value;
        bytes memory data = transaction.data;
        if (transaction.flag.isDelegateCall()) {
            // Ignore value here as we are doing delegatecall.
            (result.success, result.data) = address(to).delegatecall(data);
        } else {
            (result.success, result.data) = address(to).call{value: value}(data);
        }
    }

    /// @dev The contract itself.
    function _getAccountAddress() internal view override returns (address account) {
        return (address(this));
    }
}
```

## 发起交易

`Delegate` 可通过 `execTransaction()` 或 `execTransactions()` 发起调用。

以 `execTransaction()` 为例，其参数是一个 `CallData` 结构体。
```
struct CallData {
    uint256 flag; // 0x1 delegate call, 0x0 call.
    address to;
    uint256 value;
    bytes data; // calldata
    bytes hint;
    bytes extra; // for future support: signatures etc.
}
```

结构体各个字段表示如下：
- **flag** 表示合约调用的类型，使用 `0` 表示 `call`， `1` 表示 `delegatecall`。需要注意两种 call 形式对应的授权管理通常是独立的。
- **to** 表示调用的目标合约
- **value** 表示合约调用时转账的 ETH 数量
- **data** 表示合约调用的 calldata 数据，是合约调用的 `abi.encode` 后的结果
- **hint** 字段用于提示 **Authorizer** 使用的检查规则，当设置了 `hint` 字段后，可以在进行权限检查时执行快速路径，从而节约一定 gas。

`hint` 字段不需要用户自行计算，可通过以 `eth_call` 的形式发起一次未设置 `hint` 的交易， `execTransaction()` 返回的 `TransactionResult` 的 `hint` 即为本次交易的 `hint`，此时再次进行合约调用即可。

上述过程被封装到 CoboSafe SDK 中，使用 Javascript CoboSafe SDK 与 CoboSafe 合约进行交互示例如下：

```js
const {CoboSafeAccount} = require("./coboaccount.js");
const {ethers} = require("ethers");
const ERC20_ABI = require("./abi/ERC20.json");

require("dotenv").config();
const PRI_KEY = process.env.PRIV;
const COBO_SAFE_ADDRESS = process.env.COBOSAFE

const provider = new ethers.JsonRpcProvider("https://rpc.ankr.com/polygon")
const signer = new ethers.Wallet(PRI_KEY, provider);
const coboSafe = new CoboSafeAccount(COBO_SAFE_ADDRESS, signer)
const delegate = coboSafe.delegate;

const WMATIC_ADDRESS = "0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270";

async function main(){
    const token = new ethers.Contract(WMATIC_ADDRESS, ERC20_ABI, coboSafe);

    console.log(await token.balanceOf(await coboSafe.safe()))
    let tx = await token.transfer(delegate, 1);
    await tx.wait()
    console.log(await token.balanceOf(await coboSafe.safe()))
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
```

`Cobo Safe` 提供了 Python 和 Javascript SDK，更多 SDK 使用可参考 https://github.com/coboglobal/