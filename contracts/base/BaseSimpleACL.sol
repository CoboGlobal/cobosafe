// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./BaseSimpleAuthorizer.sol";
import "./BaseSelfCallAuth.sol";

/// @title BaseSimpleACL - Basic ACL template which uses the call-self trick to perform function and parameters check.
/// @author Cobo Safe Dev Team https://www.cobo.com/
/// @dev Steps to extend this:
///        1. Set the NAME, VERSION, TYPE, flag
///        2. Write ACL functions according the target contract.
///        3. Add a constructor. eg:
///           `constructor(address _owner) BaseSimpleACL(_owner) {}`
///        4. Override `contracts()` to only target contracts that you checks. Transactions
////          whose `to` address is not in the list will revert.
///
///      NOTE for ACL developers:
///        1. The checking functions can be defined extractly the same as the target method
///           to control thus developers do not bother to write a lot `abi.decode` code.
///        2. Checking funtions should NOT contain return value, use `require` to perform check.
///        3. BaseACL may serve for multiple target contracts.
///            - Implement contracts() to manage the target contracts set.
///            - Use `onlyContract` modifier or check `_txn().to` in checking functions.
///        4. `onlyOwner` modifier should be used for customized setter functions.

abstract contract BaseSimpleACL is BaseSimpleAuthorizer, BaseSelfCallAuth {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /// @dev Set such constants in sub contract.
    // bytes32 public constant NAME = "BaseSimpleACL";
    // bytes32 public constant override TYPE = "ACLType";
    // uint256 public constant VERSION = 0;
    // uint256 public constant flag = AuthFlags.SIMPLE_MODE
    constructor(address _owner, address _caller) BaseSimpleAuthorizer(_owner, _caller) {}

    function _preExecCheck(
        TransactionData calldata transaction
    ) internal view virtual override returns (AuthorizerReturnData memory authData) {
        return _selfStaticCallCheck(transaction);
    }

    /// External functions

    /// @dev Override contracts to set valid contract targets.

    // function contracts() public view virtual returns (address[] memory _contracts) {
    //        _contracts = new address[](1);
    //        _contracts[0] = USDT_ADDR;
    // }

    /// @dev Implement your own access control checking functions here.
    /// See BaseSelfCallAuth.sol.

    // example:

    // function transfer(address to, uint256 amount)
    //     onlyContract(USDT_ADDR)
    //     external view
    // {
    //     require(amount > 0 & amount < 10000, "amount not in range");
    // }
}
