// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "./Constants.sol";
import "../BaseTokenSetter.sol";
import "../BasePermission.sol";

abstract contract AaveWithdrawBase is BasePermission, BaseTokenSetter {
    address public immutable LendingPool;
    address public immutable WrappedTokenGateWay;
    address public immutable aWETH;

    constructor(
        address _owner,
        address _caller,
        address _LendingPool,
        address _WrappedTokenGateWay,
        address _aWETH
    ) BasePermission(_owner, _caller) {
        LendingPool = _LendingPool;
        WrappedTokenGateWay = _WrappedTokenGateWay;
        aWETH = _aWETH;
    }

    //acl function
    function withdraw(address asset, uint256 amount, address to) external view onlyContract(LendingPool) {
        _checkRecipient(to);
        _checkAllowedToken(asset);
    }

    function withdrawETH(address, uint256 amount, address to) external view onlyContract(WrappedTokenGateWay) {
        _checkAllowedToken(ETH);
        _checkRecipient(to);
    }

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](2);
        _contracts[0] = LendingPool;
        _contracts[1] = WrappedTokenGateWay;
    }

    function _addAllowedToken(address _token) internal override {
        if (_token == ETH) {
            _addTokenSpender(aWETH, WrappedTokenGateWay);
        }
        super._addAllowedToken(_token);
    }
}

contract AaveV2Withdraw is AaveWithdrawBase {
    bytes32 public constant NAME = "AaveV2Withdraw";
    uint256 public constant VERSION = 1;

    constructor(
        address _owner,
        address _caller
    )
        AaveWithdrawBase(
            _owner,
            _caller,
            AaveV2Addresses.Pool(),
            AaveV2Addresses.WETHGateway(),
            AaveV2Addresses.aWETH()
        )
    {}
}

contract AaveV3Withdraw is AaveWithdrawBase {
    bytes32 public constant NAME = "AaveV3Withdraw";
    uint256 public constant VERSION = 1;

    constructor(
        address _owner,
        address _caller
    )
        AaveWithdrawBase(
            _owner,
            _caller,
            AaveV3Addresses.Pool(),
            AaveV3Addresses.WETHGateway(),
            AaveV3Addresses.aWETH()
        )
    {}
}
