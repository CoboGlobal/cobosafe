## Cobo Smart Account

`Cobo Smart Account` 一个简单的智能合约钱包，钱包的资产保存在 `Cobo Smart Account` 本身的智能合约中。其 `Account Address` 就是合约自身。`Cobo Smart Account` 可直接通过 `call` 和 `delegatecall` 发起交易。

如下：
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
