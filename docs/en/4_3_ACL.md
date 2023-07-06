## BaseACL

To implement access controls for a contract call using `BaseAuthorizer`, developers would typically need to manually write `abi.decode` codes in order to decode [complicated transaction data](https://docs.soliditylang.org/en/latest/abi-spec.html).

To simplify this process, `Cobo Safe` has introduced the `BaseACL` contract, which is based upon `BaseAuthorizer`.

Developers can use `BaseACL` to define a function declaration to be exactly the same as the function of the target contract they intend to control. By doing so, the compiler will automatically generate the decoding codes. Developers can then focus on coding the core access control logic within the function body.

`BaseACL` only implements the `preExecCheck` function, which is commonly used for access control validation. Developers can, however, extend `BaseACL` to configure customized access controls at both the address and function levels.

The process of using `BaseACL` to implement a customized `Authorizer` is as follows: 

1. Configure variables such as `NAME` and `VERSION`.
2. Implement the `contracts()` function. A list of smart contract addresses controlled by the  `Authorizer` will be returned. The `Authorizer` will continue the validation process only if the `to` address of a transaction is in the whitelist. Otherwise, the `Authorizer` will directly reject the transaction.
3. Implement functions that are used to conduct access control validation for the target contract. These functions should be exactly the same as the function declarations of the target contract. However, they should not return any values and should not be decorated as `payable`. We recommend that you convert them to `external view` (i.e., modifying the smart contract state is not allowed). If you choose not to follow this approach, additional caller checks must be placed appropriately.
4. When a validation function is called, its parameters must be identical to those used in the smart contract call. This ensures that you can verify the parameters in a validation function body by directly using Solidity's `require()` statement. If the validation fails, the `Authorizer` will reject the transaction.
5. If the `Authorizer` needs to manage multiple smart contracts, a `modifier` named `onlyContract` must be used in a validation function to verify the contract address of the transaction. This prevents the `Delegate` from calling another smart contract that contains the same function.

The following example uses `BaseACL` to implement a customized `Authorizer`. The `Authorizer` allows `Delegate` to engage in yield farming activities on PancakeSwap.

* `Delegate` is allowed to call the `approve()` function of LP Token but the `spender` is restricted to `MasterChef`.
* `Delegate` is allowed to call the `deposit()` function of `MasterChef` and the `pid` parameter value is 3.
* `Delegate` is allowed to call the `withdraw()` function of `MasterChef` and the `pid` parameter value is 3.

```solidity
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../base/BaseACL.sol";

contract SampleFarmACL is BaseACL {
    bytes32 public constant NAME = "SampleFarmACL";
    uint256 public constant VERSION = 1;

    address public constant LP_TOKEN = 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16;
    address public constant MASTER_CHEF = 0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652;

    constructor(address _owner, address _caller) BaseACL(_owner, _caller) {}

    // Configure a list of smart contracts controlled by Authorizer
    // Transaction to addressess beyond this list will be rejected
    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](2);
        _contracts[0] = LP_TOKEN;
        _contracts[1] = MASTER_CHEF;
    }

    // When approve() is called for LP Token only MasterChef address
    // is a valid spender.
    function approve(address spender, uint256 amount) 
        external view 
        onlyContract(LP_TOKEN)
    {
        require(spender == MASTER_CHEF, "approve: Invalid spender");
    }

    // When deposit() function is called the pid parameter value should be 3
    function deposit(uint256 _pid, uint256 _amount) 
        external view 
        onlyContract(MASTER_CHEF)
    {
        require(_pid == 3, "deposit: Pool is not allowed");
    }

    // When withdraw() function is called the pid parameter value should be 3
    function withdraw(uint256 _pid, uint256 _amount) 
        external view 
        onlyContract(MASTER_CHEF)
    {
        require(_pid == 3, "withdraw: Pool is not allowed");
    }
}
```
