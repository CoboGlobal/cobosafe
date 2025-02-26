// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "./Constants.sol";
import "../BaseTokenSetter.sol";
import "../BasePermission.sol";

abstract contract AaveDisableCollateralBase is BasePermission, BaseTokenSetter {
    address public immutable LendingPool;

    constructor(address _owner, address _caller, address _LendingPool) BasePermission(_owner, _caller) {
        LendingPool = _LendingPool;
    }

    //acl function
    function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external view {
        _checkAllowedToken(asset);
        require(useAsCollateral == false, "Can only disable collateral");
    }

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = LendingPool;
    }
}

contract AaveV2DisableCollateral is AaveDisableCollateralBase {
    bytes32 public constant NAME = "AaveV2DisableCollateral";
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) AaveDisableCollateralBase(_owner, _caller, AaveV2Addresses.Pool()) {}
}

contract AaveV3DisableCollateral is AaveDisableCollateralBase {
    bytes32 public constant NAME = "AaveV3DisableCollateral";
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) AaveDisableCollateralBase(_owner, _caller, AaveV3Addresses.Pool()) {}
}
