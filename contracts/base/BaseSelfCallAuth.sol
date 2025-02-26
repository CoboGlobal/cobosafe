// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../Types.sol";
import "../Errors.sol";

contract BaseSelfCallAuth {
    /// Internal functions.
    function _parseReturnData(
        bool success,
        bytes memory revertData
    ) internal pure returns (AuthorizerReturnData memory authData) {
        if (success) {
            // ACL checking functions should not return any bytes which differs from normal view functions.
            require(revertData.length == 0, Errors.ACL_FUNC_RETURNS_NON_EMPTY);
            authData.result = AuthResult.SUCCESS;
        } else {
            if (revertData.length < 68) {
                // 4(Error sig) + 32(offset) + 32(length)
                authData.message = string(revertData);
            } else {
                assembly {
                    // Slice the sighash.
                    revertData := add(revertData, 0x04)
                }
                authData.message = abi.decode(revertData, (string));
            }
        }
    }

    function _packTxn(TransactionData calldata transaction) internal pure virtual returns (bytes memory) {
        bytes memory txnData = abi.encode(transaction);
        bytes memory callDataSize = abi.encode(transaction.data.length);
        return abi.encodePacked(transaction.data, txnData, callDataSize);
    }

    function _unpackTxn() internal pure virtual returns (TransactionData memory transaction) {
        uint256 end = msg.data.length;
        uint256 callDataSize = abi.decode(msg.data[end - 32:end], (uint256));
        transaction = abi.decode(msg.data[callDataSize:], (TransactionData));
    }

    // @dev Only valid in self-call checking functions.
    function _txn() internal pure virtual returns (TransactionData memory transaction) {
        return _unpackTxn();
    }

    // Utilities for checking functions.
    function _checkRecipient(address _recipient) internal pure {
        require(_recipient == _txn().from, "Invalid recipient");
    }

    function _checkContract(address _contract) internal pure {
        require(_contract == _txn().to, "Invalid contract");
    }

    // Modifiers.

    modifier onlyContract(address _contract) {
        _checkContract(_contract);
        _;
    }

    modifier onlySender(address _recipient) {
        _checkRecipient(_recipient);
        _;
    }

    modifier nonPayable() {
        require(_txn().value == 0, "Invalid tx value");
        _;
    }

    function _contractCheck(TransactionData calldata transaction) internal view virtual returns (bool result) {
        // This works as a catch-all check. Sample but safer.
        address to = transaction.to;
        address[] memory _contracts = contracts();
        for (uint i = 0; i < _contracts.length; i++) {
            if (to == _contracts[i]) return true;
        }
        return false;
    }

    function _selfStaticCallCheck(
        TransactionData calldata transaction
    ) internal view returns (AuthorizerReturnData memory authData) {
        if (!_contractCheck(transaction)) {
            authData.result = AuthResult.FAILED;
            authData.message = Errors.NOT_IN_CONTRACT_LIST;
            return authData;
        }
        (bool success, bytes memory revertData) = address(this).staticcall(_packTxn(transaction));
        return _parseReturnData(success, revertData);
    }

    function _selfCallCheck(
        TransactionData calldata transaction
    ) internal returns (AuthorizerReturnData memory authData) {
        if (!_contractCheck(transaction)) {
            authData.result = AuthResult.FAILED;
            authData.message = Errors.NOT_IN_CONTRACT_LIST;
            return authData;
        }

        (bool success, bytes memory revertData) = address(this).call(_packTxn(transaction));
        return _parseReturnData(success, revertData);
    }

    fallback() external virtual {
        revert(Errors.METHOD_NOT_ALLOW);
    }

    /// @dev Override this cause it is used by `_preExecCheck`.
    /// @notice Target contracts this BaseACL controls.
    function contracts() public view virtual returns (address[] memory _contracts) {}

    /// @dev Implement your own access control checking functions here.

    // example:

    // function transfer(address to, uint256 amount)
    //     onlyContract(USDT_ADDR)
    //     external view
    // {
    //     require(amount > 0 & amount < 10000, "amount not in range");
    // }
}
