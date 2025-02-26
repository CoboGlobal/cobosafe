// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../base/BaseSimpleAuthorizer.sol";

/// @title RevokeAuthorizer - Revoke ERC20 allowance.
/// @author Cobo Safe Dev Team https://www.cobo.com/
/// @notice This checks value, only 0 allowed.
contract RevokeAuthorizer is BaseSimpleAuthorizer {
    bytes32 public constant NAME = "RevokeAuthorizer";
    uint256 public constant VERSION = 1;
    bytes32 public constant override TYPE = AuthType.REVOKE;

    // function approve(address spender, uint256 value)
    bytes4 constant APPROVE_SELECTOR = 0x095ea7b3;

    constructor(address _owner, address _caller) BaseSimpleAuthorizer(_owner, _caller) {}

    function _preExecCheck(
        TransactionData calldata transaction
    ) internal view virtual override returns (AuthorizerReturnData memory authData) {
        if (
            transaction.data.length >= 68 && // 4 + 32 + 32
            bytes4(transaction.data[0:4]) == APPROVE_SELECTOR &&
            transaction.value == 0
        ) {
            (, uint256 value) = abi.decode(transaction.data[4:], (address, uint256));
            if (value == 0) {
                authData.result = AuthResult.SUCCESS;
                return authData;
            }
        }
        authData.result = AuthResult.FAILED;
        authData.message = "value other than 0 not allowed";
    }
}
