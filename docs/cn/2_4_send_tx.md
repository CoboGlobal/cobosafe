## 发起交易

`Delegate` 可通过 `execTransaction()` 或 `execTransactions()` 发起调用。

以 `execTransaction()` 为例，其参数是一个 `CallData` 结构体。
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

`Cobo Safe` 提供了[Python](https://github.com/coboglobal/pycobosafe) 和 [Javascript](https://github.com/coboglobal/jscobosafe) 的 SDK。