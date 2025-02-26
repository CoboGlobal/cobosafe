// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../auth/BaseApprovalAuthorizer.sol";
import "../auth/DEXBaseACL.sol";

abstract contract BaseDexPermission is BaseApprovalAuthorizer, DEXBaseACL {
    /// @dev Set such constants in the sub contract.
    // bytes32 public constant NAME = "BasePermission";
    // uint256 public constant VERSION = 0;
    // uint256 public constant flag = AuthFlags.SIMPLE_MODE

    using EnumerableSet for EnumerableSet.AddressSet;

    constructor(address _owner, address _caller) BaseApprovalAuthorizer() DEXBaseACL(_owner, _caller) {}

    function TYPE() external view virtual override(BaseSimpleAuthorizer, DEXBaseACL) returns (bytes32) {
        return AuthType.DEX;
    }

    // internal
    function _commonDexCheck(address to, address tokenIn, address tokenOut) internal view {
        _checkRecipient(to);
        _swapInOutTokenCheck(tokenIn, tokenOut);
    }

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
}
