// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "./AaveRateModeBase.sol";
import "./Constants.sol";
import "../BaseTokenSetter.sol";
import "../BasePermission.sol";

abstract contract AaveBorrowBase is BasePermission, AaveRateModeBase, BaseTokenSetter {
    address public immutable aETHVariableDebtToken;
    address public immutable aETHStableDebtToken;
    address public immutable LendingPool;
    address public immutable WrappedTokenGateWay;

    constructor(
        address _owner,
        address _caller,
        address _aETHVariableDebtToken,
        address _aETHStableDebtToken,
        address _LendingPool,
        address _WrappedTokenGateWay
    ) BasePermission(_owner, _caller) {
        aETHVariableDebtToken = _aETHVariableDebtToken;
        aETHStableDebtToken = _aETHStableDebtToken;
        LendingPool = _LendingPool;
        WrappedTokenGateWay = _WrappedTokenGateWay;
    }

    //acl function
    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external view onlyContract(LendingPool) {
        _checkRecipient(onBehalfOf);
        _checkAllowedToken(asset);
        _checkInterestRate(interestRateMode);
    }

    function approveDelegation(address delegatee, uint256 amount) external view {
        require(delegatee == WrappedTokenGateWay, "Invalid delegatee");
    }

    function borrowETH(
        address,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode
    ) external view onlyContract(WrappedTokenGateWay) {
        _checkAllowedToken(Addresses.ETH);
        _checkInterestRate(interestRateMode);
    }

    // function swapBorrowRateMode(address asset, uint256 rateMode)
    //     external view
    //     onlyContract(LendingPool) {

    // }

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](4);
        _contracts[0] = LendingPool;
        _contracts[1] = WrappedTokenGateWay;
        _contracts[2] = aETHVariableDebtToken;
        _contracts[3] = aETHStableDebtToken;
    }
}

contract AaveV2Borrow is AaveBorrowBase {
    bytes32 public constant NAME = "AaveV2Borrow";
    uint256 public constant VERSION = 1;

    constructor(
        address _owner,
        address _caller
    )
        AaveBorrowBase(
            _owner,
            _caller,
            AaveV2Addresses.variableDebtWETH(),
            AaveV2Addresses.stableDebtWETH(),
            AaveV2Addresses.Pool(),
            AaveV2Addresses.WETHGateway()
        )
    {}
}

contract AaveV3Borrow is AaveBorrowBase {
    bytes32 public constant NAME = "AaveV3Borrow";
    uint256 public constant VERSION = 1;

    constructor(
        address _owner,
        address _caller
    )
        AaveBorrowBase(
            _owner,
            _caller,
            AaveV3Addresses.variableDebtWETH(),
            AaveV3Addresses.stableDebtWETH(),
            AaveV3Addresses.Pool(),
            AaveV3Addresses.WETHGateway()
        )
    {}
}
