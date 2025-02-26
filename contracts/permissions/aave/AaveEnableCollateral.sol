// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "./Constants.sol";
import "../BaseTokenSetter.sol";
import "../BasePermission.sol";

abstract contract AaveEnableCollateralBase is BasePermission, BaseTokenSetter {
    address public immutable LendingPool;

    constructor(address _owner, address _caller, address _LendingPool) BasePermission(_owner, _caller) {
        LendingPool = _LendingPool;
    }

    //acl function
    function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external view {
        _checkAllowedToken(asset);
        require(useAsCollateral == true, "Can only enable collateral");
    }

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = LendingPool;
    }
}

contract AaveV2EnableCollateral is AaveEnableCollateralBase {
    bytes32 public constant NAME = "AaveV2EnableCollateral";
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) AaveEnableCollateralBase(_owner, _caller, AaveV2Addresses.Pool()) {}
}

contract AaveV3EnableCollateral is AaveEnableCollateralBase {
    bytes32 public constant NAME = "AaveV3EnableCollateral";
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) AaveEnableCollateralBase(_owner, _caller, AaveV3Addresses.Pool()) {}
}
