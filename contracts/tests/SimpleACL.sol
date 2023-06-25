// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../base/BaseACL.sol";

contract TransferACL1 is BaseACL {
    bytes32 public constant NAME = "TransferACL1";
    uint256 public constant VERSION = 1;

    address public immutable token;

    constructor(address _owner, address _caller, address _token) BaseACL(_owner, _caller) {
        token = _token;
    }

    function _contractCheck(TransactionData calldata transaction) internal override returns (bool result) {
        // Remove common target address check.
        return true;
    }

    function transfer(address to, uint256 amount) external view {
        TransactionData memory txn = _txn();
        address _contract = txn.to;
        uint256 value = txn.value;
        require(value == 0, "Non-payable");
        require(token == _contract, "token not in whitelist");
        require(amount >= 0 && amount <= 10000, "amount not in range");
    }
}

contract TransferACL2 is BaseACL {
    bytes32 public constant NAME = "TransferACL2";
    uint256 public constant VERSION = 1;

    address public immutable token;

    constructor(address _owner, address _caller, address _token) BaseACL(_owner, _caller) {
        token = _token;
    }

    function _contractCheck(TransactionData calldata transaction) internal override returns (bool result) {
        // Remove common target address check.
        return true;
    }

    function transfer(address to, uint256 amount) external view {
        TransactionData memory txn = _txn();
        address _contract = txn.to;
        uint256 value = txn.value;
        require(value == 0, "Non-payable");
        require(token == _contract, "token not in whitelist");
        require(amount >= 5000 && amount <= 15000, "amount not in range");
    }
}

contract TransferACL3 is BaseACL {
    bytes32 public constant NAME = "TransferACL3";
    uint256 public constant VERSION = 1;

    address public immutable token;

    constructor(address _owner, address _caller, address _token) BaseACL(_owner, _caller) {
        token = _token;
    }

    function _contractCheck(TransactionData calldata transaction) internal override returns (bool result) {
        // Remove common target address check.
        return true;
    }

    function transfer(address to, uint256 amount) external view {
        TransactionData memory txn = _txn();
        address _contract = txn.to;
        uint256 value = txn.value;
        require(value == 0, "Non-payable");
        require(token == _contract, "token not in whitelist");
        require(amount >= 0 && amount <= 15000, "amount not in range");
    }
}

contract AllowAllACL is BaseACL {
    bytes32 public constant NAME = "AllowAllACL";
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) BaseACL(_owner, _caller) {}

    function _contractCheck(TransactionData calldata transaction) internal override returns (bool result) {
        // Remove common target address check.
        return true;
    }

    fallback() external override {
        // allow all.
    }
}
