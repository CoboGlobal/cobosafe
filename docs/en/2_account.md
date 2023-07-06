# Cobo Account

`Cobo Account` is the smart contract wallet in a `Cobo Safe` framework. Each `Cobo Account` contract should implement the `Account` interface as follows:

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

Developers can also derive smart contracts from the `Cobo Account` base contract to adapt to different underlying smart contract wallets (e.g., Safe).

A `Delegate` can call the `execTransaction()` function to send transactions. The `execTransaction()` function will invoke the `Authorizer` module to verify whether the `Delegate` is authorized to execute such transactions. 

The `getAccountAddress()` function will return a wallet address where the funds are stored and where the transactions originated from.
