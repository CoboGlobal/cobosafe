// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "./AaveRateModeBase.sol";
import "./Constants.sol";
import "../BaseTokenSetter.sol";
import "../BasePermission.sol";

abstract contract AaveRepayBase is BasePermission, AaveRateModeBase, BaseTokenSetter {
    address public immutable LendingPool;
    address public immutable WrappedTokenGateWay;

    constructor(
        address _owner,
        address _caller,
        address _LendingPool,
        address _WrappedTokenGateWay
    ) BasePermission(_owner, _caller) {
        LendingPool = _LendingPool;
        WrappedTokenGateWay = _WrappedTokenGateWay;
    }

    //acl function
    function repay(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        address onBehalfOf
    ) external view onlyContract(LendingPool) {
        _checkRecipient(onBehalfOf);
        _checkAllowedToken(asset);
        _checkInterestRate(interestRateMode);
    }

    function repayETH(
        address,
        uint256 amount,
        uint256 rateMode,
        address onBehalfOf
    ) external view onlyContract(WrappedTokenGateWay) {
        _checkAllowedToken(ETH);
        _checkInterestRate(rateMode);
        _checkRecipient(onBehalfOf);
    }

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](2);
        _contracts[0] = LendingPool;
        _contracts[1] = WrappedTokenGateWay;
    }

    function _addAllowedToken(address _token) internal override {
        if (_token != ETH) {
            _addTokenSpender(_token, LendingPool);
        }
        super._addAllowedToken(_token);
    }
}

contract AaveV2Repay is AaveRepayBase {
    bytes32 public constant NAME = "AaveV2Repay";
    uint256 public constant VERSION = 1;

    constructor(
        address _owner,
        address _caller
    ) AaveRepayBase(_owner, _caller, AaveV2Addresses.Pool(), AaveV2Addresses.WETHGateway()) {}
}

contract AaveV3Repay is AaveRepayBase {
    bytes32 public constant NAME = "AaveV3Repay";
    uint256 public constant VERSION = 1;

    constructor(
        address _owner,
        address _caller
    ) AaveRepayBase(_owner, _caller, AaveV3Addresses.Pool(), AaveV3Addresses.WETHGateway()) {}

    function repayWithATokens(
        address asset,
        uint256 amount,
        uint256 interestRateMode
    ) external view onlyContract(LendingPool) {
        _checkAllowedToken(asset);
        _checkInterestRate(interestRateMode);
    }
}
