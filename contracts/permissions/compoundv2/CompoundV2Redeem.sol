// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../BasePermission.sol";
import "../BaseTokenSetter.sol";

contract CompoundV2Redeem is BasePermission, BaseTokenSetter {
    bytes32 public constant NAME = "CompoundV2Redeem";
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) BasePermission(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = getAllowedTokens();
    }

    function _contractCheck(TransactionData calldata transaction) internal view override returns (bool result) {
        address to = transaction.to;
        // Targets should be cToken
        return _hasAllowedToken(to);
    }

    function redeem(uint redeemTokens) external pure {}

    function redeemUnderlying(uint redeemAmount) external pure {}
}
