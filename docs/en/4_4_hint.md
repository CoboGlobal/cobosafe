## Hint

You can add additional data, referred to as `hint`, during a smart contract call in order to accelerate the validation process and save on gas fees.

The `hint` field can be passed in in a `CallData` struct as follows when a transaction is sent to an `Authorizer`:

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

With `ArgusRootAuthorizer`, for instance, multiple `Roles` can be assigned to a `Delegate` and each `Role` can be associated with multiple `Authorizers`. A transaction will be approved if it successfully passes validation from any of these `Authorizers`. In this case, `Role` and `Authorizer` can be used as `hint` to determine the specific `Authorizer` whose validation the transaction will pass:

1. Execute the `execTransaction()` function by making an `eth_call` call without setting the `hint` field. The `hint` field returned in `TransactionResult` will be the `hint` of this transaction.
2. Pass in this `hint` to `CallData`.
3. Decode `hint` in `ArgusRootAuthorizer` to query the `Role` and `Authorizer`.
4. Use `Role Manager` to validate whether the `Role` obtained in step 3 corresponds to the `Delegate` of this transaction.
5. Validate whether the `Authorizer` obtained in step 3 has been registered in `ArgusRootAuthorizer`.
6. The `hint` is considered invalid if either step 4 or step 5 fails. The transaction will be directly rejected.
7. The `hint` is considered valid if both step 4 and step 5 succeed. You can use the `Authorizer` specified in the `hint` to validate the transaction.
