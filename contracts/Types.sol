// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

struct CallData {
    uint256 flag; // 0x1 delegate call, 0x0 call.
    address to;
    uint256 value;
    bytes data; // calldata
    bytes hint;
    bytes extra; // for future support: signatures etc.
}

struct TransactionData {
    address from; // `msg.sender` who performs the transaction a.k.a wallet address.
    address delegate; // Delegate who calls executeTransactions().
    // Same as CallData
    uint256 flag; // 0x1 delegate call, 0x0 call.
    address to;
    uint256 value;
    bytes data; // calldata
    bytes hint;
    bytes extra;
}

/// @dev Use enum instead of bool in case of when other status, like PENDING,
///      is needed in the future.
enum AuthResult {
    FAILED,
    SUCCESS
}

struct AuthorizerReturnData {
    AuthResult result;
    string message;
    bytes data; // Authorizer return data. usually used for hint purpose.
}

struct TransactionResult {
    bool success; // Call status.
    bytes data; // Return/Revert data.
    bytes hint;
}

library TxFlags {
    uint256 internal constant DELEGATE_CALL_MASK = 0x1; // 1 for delegatecall, 0 for call
    uint256 internal constant ALLOW_REVERT_MASK = 0x2; // 1 for allow, 0 for not

    function isDelegateCall(uint256 flag) internal pure returns (bool) {
        return flag & DELEGATE_CALL_MASK > 0;
    }

    function allowsRevert(uint256 flag) internal pure returns (bool) {
        return flag & ALLOW_REVERT_MASK > 0;
    }
}

library AuthType {
    bytes32 internal constant FUNC = "FunctionType";
    bytes32 internal constant ADDRESS = "AddressType";
    bytes32 internal constant RATE = "RateType";
    bytes32 internal constant TRANSFER = "TransferType";
    bytes32 internal constant APPROVE = "ApproveType";
    bytes32 internal constant REVOKE = "RevokeType";
    bytes32 internal constant DEX = "DexType";
    bytes32 internal constant LENDING = "LendingType";
    bytes32 internal constant COMMON = "CommonType";
    bytes32 internal constant SET = "SetType";
    bytes32 internal constant VM = "VM";
    bytes32 internal constant PERMISSION = "Permission";
}

library AuthFlags {
    uint256 internal constant HAS_PRE_CHECK_MASK = 0x1;
    uint256 internal constant HAS_POST_CHECK_MASK = 0x2;
    uint256 internal constant HAS_PRE_PROC_MASK = 0x4;
    uint256 internal constant HAS_POST_PROC_MASK = 0x8;

    uint256 internal constant STATIC_AUTH_MASK = 0x10;
    uint256 internal constant IMMUTABLE_MASK = 0x20;

    uint256 internal constant SUPPORT_HINT_MASK = 0x40;

    uint256 internal constant FULL_MODE =
        HAS_PRE_CHECK_MASK | HAS_POST_CHECK_MASK | HAS_PRE_PROC_MASK | HAS_POST_PROC_MASK;

    uint256 internal constant SIMPLE_MODE = HAS_PRE_CHECK_MASK | STATIC_AUTH_MASK;
    uint256 internal constant SIMPLE_IMMUTABLE_MODE = SIMPLE_MODE | IMMUTABLE_MASK;

    function isValid(uint256 flag) internal pure returns (bool) {
        // At least one check handler is activated.
        return hasPreCheck(flag) || hasPostCheck(flag);
    }

    function hasPreCheck(uint256 flag) internal pure returns (bool) {
        return flag & HAS_PRE_CHECK_MASK > 0;
    }

    function hasPostCheck(uint256 flag) internal pure returns (bool) {
        return flag & HAS_POST_CHECK_MASK > 0;
    }

    function hasPreProcess(uint256 flag) internal pure returns (bool) {
        return flag & HAS_PRE_PROC_MASK > 0;
    }

    function hasPostProcess(uint256 flag) internal pure returns (bool) {
        return flag & HAS_POST_PROC_MASK > 0;
    }

    function supportHint(uint256 flag) internal pure returns (bool) {
        return flag & SUPPORT_HINT_MASK > 0;
    }

    function isStatic(uint256 flag) internal pure returns (bool) {
        return flag & STATIC_AUTH_MASK > 0;
    }

    function isImmutable(uint256 flag) internal pure returns (bool) {
        return flag & IMMUTABLE_MASK > 0;
    }
}
