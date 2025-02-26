// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../base/BaseOwnable.sol";

abstract contract AaveRateModeBase is BaseOwnable {
    bool public stableRateMode;
    bool public variableRateMode;

    function setStableRateMode(bool _isEnableStableRate) external onlyOwner {
        stableRateMode = _isEnableStableRate;
    }

    function setVariableRateMode(bool _isEnableVariableRate) external onlyOwner {
        variableRateMode = _isEnableVariableRate;
    }

    function _checkInterestRate(uint256 interestRateMode) internal view {
        if (interestRateMode == 1) {
            require(stableRateMode, "Only stable rate mode is allowed");
        } else if (interestRateMode == 2) {
            require(variableRateMode, "Only variable rate mode is allowed");
        } else {
            revert("interest rate mode not set");
        }
    }
}
