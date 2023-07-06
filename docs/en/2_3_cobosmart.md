## Cobo Smart Account

`Cobo Smart Account` is a simple smart contract wallet for storing digital assets and sending transactions.

The `Account Address` of a `Cobo Smart Account` will be the address of the underlying smart contract.&#x20;

`Cobo Smart Account` sends transactions using  `call` and  `delegatecall` as follows:

```solidity
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
