## Send Transactions

`Delegate` can call either `execTransaction()` or `execTransactions()` to send transactions.&#x20;

The following uses `execTransaction()` as an example, where the `CallData` struct is passed in as a parameter.&#x20;

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

Each field in the struct is defined as follows: &#x20;

* **flag:** The call type. `0` indicates `call` and `1` indicates `delegatecall`. Note that each type of call comes with different access controls.
* **to**: The target smart contract to be called. &#x20;
* **value**: The ETH amount of the transaction when the contract is called.&#x20;
* **data**: The `calldata` of a transaction (i.e., `abi.encoded` parameters of a contract call).
* **hint**: When the `hint` field is set, the `Authorizer` will optimize the validation process by executing a fast path. This helps reduce gas consumption.

To generate a `hint`, you can execute an `eth_call` to the `execTransaction()` function with the `hint` field left unset. The `TransactionResult` returned from the call will contain the correct `hint` value.

The above process can be achieved using [Cobo Safe SDKs](https://developers.cobo.com/smart-contract-custody/sdk/js). The following uses Cobo Safe SDKs in Javascript as an example.

```js
const {CoboSafeAccount} = require("jscobosafe");
const {ethers} = require("ethers");
const ERC20_ABI = require("./ERC20.json");

require("dotenv").config();
const PRI_KEY = process.env.PRIV;
const COBO_SAFE_ADDRESS = process.env.COBOSAFE

const provider = new ethers.JsonRpcProvider("https://rpc.ankr.com/polygon")
const signer = new ethers.Wallet(PRI_KEY, provider);
const coboSafe = new CoboSafeAccount(COBO_SAFE_ADDRESS, signer)
const delegate = coboSafe.delegate;

const WMATIC_ADDRESS = "0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270";

async function main(){
    console.log("CoboSafe", coboSafe.address);
    console.log("Safe", await coboSafe.safe());
    console.log("Delegate", coboSafe.delegate);

    let tx;

    // Connect with the contract as other ethers.js signers do.
    const token = new ethers.Contract(WMATIC_ADDRESS, ERC20_ABI, coboSafe);

    console.log(await token.balanceOf(await coboSafe.safe()))
    tx = await token.transfer(delegate, 1);
    await tx.wait()
    console.log(await token.balanceOf(await coboSafe.safe()))
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

```

`Cobo Safe` offers SDKs in [Python](https://github.com/coboglobal/pycobosafe) and [Javascript](https://github.com/coboglobal/jscobosafe). 