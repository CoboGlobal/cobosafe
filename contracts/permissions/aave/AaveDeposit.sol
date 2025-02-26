// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "./Constants.sol";
import "../BaseTokenSetter.sol";
import "../BasePermission.sol";

abstract contract AaveDepositBase is BasePermission, BaseTokenSetter {
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
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external view onlyContract(LendingPool) {
        _checkAllowedToken(asset);
        _checkRecipient(onBehalfOf);
    }

    function depositETH(
        address,
        address onBehalfOf,
        uint16 referralCode
    ) external view onlyContract(WrappedTokenGateWay) {
        _checkAllowedToken(ETH);
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

contract AaveV2Deposit is AaveDepositBase {
    bytes32 public constant NAME = "AaveV2Deposit";
    uint256 public constant VERSION = 1;

    constructor(
        address _owner,
        address _caller
    ) AaveDepositBase(_owner, _caller, AaveV2Addresses.Pool(), AaveV2Addresses.WETHGateway()) {}
}

contract AaveV3Deposit is AaveDepositBase {
    bytes32 public constant NAME = "AaveV3Deposit";
    uint256 public constant VERSION = 1;

    constructor(
        address _owner,
        address _caller
    ) AaveDepositBase(_owner, _caller, AaveV3Addresses.Pool(), AaveV3Addresses.WETHGateway()) {}

    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external view onlyContract(LendingPool) {
        _checkAllowedToken(asset);
        _checkRecipient(onBehalfOf);
    }
}
