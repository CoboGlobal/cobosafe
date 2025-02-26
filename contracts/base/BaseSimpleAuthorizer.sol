// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "./BaseOwnable.sol";
import "../Errors.sol";
import "../../interfaces/IAuthorizer.sol";
import "../../interfaces/IAccount.sol";
import "../../interfaces/IRoleManager.sol";

/// @title BaseSimpleAuthorizer - A simple ownable authorizer
/// @author Cobo Safe Dev Team https://www.cobo.com/
/// @dev Simplified `BaseAuthorizer`:
///      1. `preExecCheck` is view function thus no storage write is allowed.
///      2. Void `postExecCheck/preExecProcess/postExecProcess` implementation.
///      3. `pause` removed.
///      4. `caller` check removed.
///      5. `account` removed, thus no roles check.
///
abstract contract BaseSimpleAuthorizer is IAuthorizer, BaseOwnable {
    // Often used for off-chain system.
    // Each contract instance has its own value.
    bytes32 public tag;

    event TagSet(bytes32 indexed tag);

    constructor(address _owner, address _caller) BaseOwnable(_owner) {
        (_caller);
    }

    /// @dev Compatible to ArgusAccountHelper.createAuthorizer.
    // `_caller` is in the argument list but not actually used.
    function initialize(address _owner, address _caller) public {
        initialize(_owner);
        (_caller);
    }

    function initialize(address _owner, address _caller, address _account) external {
        initialize(_owner, _caller);
        (_account);
    }

    /// @notice Change the tag for the contract instance.
    /// @dev For off-chain index.
    /// @param _tag the tag
    function setTag(bytes32 _tag) external onlyOwner {
        tag = _tag;
        emit TagSet(_tag);
    }

    function preExecCheck(
        TransactionData calldata transaction
    ) external view virtual returns (AuthorizerReturnData memory authData) {
        return _preExecCheck(transaction);
    }

    function postExecCheck(
        TransactionData calldata transaction,
        TransactionResult calldata callResult,
        AuthorizerReturnData calldata preData
    ) external pure returns (AuthorizerReturnData memory authData) {
        (transaction, callResult, preData);
        authData.result = AuthResult.SUCCESS;
    }

    function preExecProcess(TransactionData calldata transaction) external pure {
        (transaction);
    }

    function postExecProcess(
        TransactionData calldata transaction,
        TransactionResult calldata callResult
    ) external pure {
        (transaction, callResult);
    }

    /// @dev Override this if you implement new type of authorizer.
    function TYPE() external view virtual returns (bytes32) {
        return AuthType.COMMON;
    }

    /// @dev Default flag for BaseSimpleAuthorizer. Can be overrided by sub contract.
    function flag() external view virtual override returns (uint256) {
        return AuthFlags.SIMPLE_MODE;
    }

    /// @dev Implement this function to extend this contract.
    function _preExecCheck(
        TransactionData calldata transaction
    ) internal view virtual returns (AuthorizerReturnData memory authData);
}
