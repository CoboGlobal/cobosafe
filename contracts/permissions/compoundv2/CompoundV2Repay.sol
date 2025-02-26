// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../BasePermission.sol";
import "../BaseTokenSetter.sol";

interface ICToken {
    function isCToken() external view returns (bool);

    function underlying() external view returns (address);
}

contract CompoundV2Repay is BasePermission, BaseTokenSetter {
    bytes32 public constant NAME = "CompoundV2Repay";
    uint256 public constant VERSION = 1;

    address public constant cETH = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;

    constructor(address _owner, address _caller) BasePermission(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = getAllowedTokens();
    }

    function _contractCheck(TransactionData calldata transaction) internal view override returns (bool result) {
        address to = transaction.to;
        // Targets should be cToken
        return _hasAllowedToken(to);
    }

    function _addAllowedToken(address _token) internal override {
        ICToken cToken = ICToken(_token);
        require(cToken.isCToken(), "Invalid token");

        if (_token != cETH) {
            _addTokenSpender(cToken.underlying(), _token);
        }
        super._addAllowedToken(_token);
    }

    function _removeAllowedToken(address _token) internal override {
        if (_token != cETH) {
            ICToken cToken = ICToken(_token);
            _removeTokenSpender(cToken.underlying(), _token);
        }
        super._removeAllowedToken(_token);
    }

    function repayBorrow(uint repayAmount) external view {
        require(_txn().to != cETH, "Invalid contract");
    }

    function repayBorrowBehalf(address borrower, uint repayAmount) external view onlySender(borrower) {
        require(_txn().to != cETH, "Invalid contract");
    }

    function repayBorrow() external view onlyContract(cETH) {}

    function repayBorrowBehalf(address borrower) external view onlySender(borrower) onlyContract(cETH) {}
}
