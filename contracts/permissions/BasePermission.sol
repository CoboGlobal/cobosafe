// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../base/BaseSimpleACL.sol";
import "../auth/BaseApprovalAuthorizer.sol";

/// @title BasePermission - BaseSimpleACL + BaseApprovalAuthorizer
/// @author Cobo Safe Dev Team https://www.cobo.com/
/// @dev Check token approval and contract functions in one authorizer.
///      Use it like we do with BaseSimpleACL.
///      Use _addTokenSpender() & _removeTokenSpender() for approve() auth.
abstract contract BasePermission is BaseApprovalAuthorizer, BaseSimpleACL {
    /// @dev Set such constants in the sub contract.
    // bytes32 public constant NAME = "BasePermission";
    // uint256 public constant VERSION = 0;
    // uint256 public constant flag = AuthFlags.SIMPLE_MODE

    bytes32 public constant override TYPE = AuthType.PERMISSION;

    constructor(address _owner, address _caller) BaseSimpleACL(_owner, _caller) {}

    function _preExecCheck(
        TransactionData calldata transaction
    )
        internal
        view
        virtual
        override(BaseApprovalAuthorizer, BaseSimpleACL)
        returns (AuthorizerReturnData memory authData)
    {
        // Check approve() first.
        authData = BaseApprovalAuthorizer._preExecCheck(transaction);
        if (authData.result == AuthResult.SUCCESS) {
            return authData;
        }

        // If failed, fallback to self call auth.
        return BaseSimpleACL._preExecCheck(transaction);
    }

    /// @dev Override to set valid contract targets.

    // function contracts() public view virtual override returns (address[] memory _contracts) {}

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
