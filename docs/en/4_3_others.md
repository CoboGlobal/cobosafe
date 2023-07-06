# Other Authorizers

`Cobo Safe` is embedded with multiple types of built-in `Authorizers`.

### FuncAuthorizer

`FuncAuthorizer` is a simple `Authorizer` that is used to validate the address and the function of a smart contract call.

Assume that an `Owner` wants to authorize a `Delegate` to transfer `USDT` via Ethereum. This can be achieved through the following configuration of `FuncAuthorizer`:

1. Validate that the `USDT` contract address is `0xdAC17F958D2ee523a2206206994597C13D831ec7.`
2. Validate that the transaction will invoke the `transfer(address,uint256)` function. Note that this function must follow the [`contract ABI specification`](https://docs.soliditylang.org/en/v0.8.19/abi-spec.html#function-selector).
3. Call `addContractFuncs()` or `addContractFuncsSig()` of `FuncAuthorizer` to add the above address and function. 

Please note that `FuncAuthorizer` only validates the address and the function of a smart contract call. It does not validate the parameters that are passed in when the contract is called. For example, `FuncAuthorizer` cannot be used to configure the receipt or the USDT transaction amount. You will need to manually write an ACL instead to implement access controls at the granular level.

### TransferAuthorizer

`TransferAuthorizer` allows you to validate the token `type` and `receipt` of a transaction using the `addTokenReceivers` function. The `Delegate` can transfer the authorized `type` of tokens directly to the `receipt`.

Note that for ERC-20 tokens, the token `type` will be the token address. For native tokens, the token `type` will be `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`.

### ArgusRootAuthorizer

`ArgusRootAuthorizer` is the default type of `Authorizer` on Cobo Argus. `ArgusRootAuthorizer` is not used for validation purposes. Instead, it is used to maintain a set of `Sub-Authorizers`.

`ArgusRootAuthorizer` is also designed in the [Role-Based Access Control](https://en.wikipedia.org/wiki/Role-based\_access\_control) (RBAC) framework. You can use `ArgusRootAuthorizer` to configure one or multiple `Sub-Authorizers` for each `Role`.

When a transaction is sent to `ArgusRootAuthorizer`:

1. `ArgusRootAuthorizer` will query the `Delegate` of the transaction and identify the `Role` assigned to the `Delegate` with the help of a `Role Manager`.
2. `ArgusRootAuthorizer` will query the `Sub-Authorizers` associated with each `Role`.
3. `ArgusRootAuthorizer` will call the `Sub-Authorizers` associated with each `Role`. If the transaction passes validation from any of these `Sub-Authorizers`, it will be approved. If the transaction fails validation from all of these `Sub-Authorizers`, it will be rejected.

If a `Sub-Authorizer` contains both `preExecCheck` and `postExecCheck`, a transaction will be approved only if it passes validation from both functions.
