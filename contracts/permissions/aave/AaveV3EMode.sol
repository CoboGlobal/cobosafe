// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../BasePermission.sol";
import "./Constants.sol";

contract AaveV3EMode is BasePermission {
    bytes32 public constant NAME = "AaveV3EMode";
    uint256 public constant VERSION = 1;

    address public immutable LendingPool = AaveV3Addresses.Pool();

    constructor(address _owner, address _caller) BasePermission(_owner, _caller) {}

    function setUserEMode(uint8 categoryId) external view {
        // allow
    }

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = LendingPool;
    }
}
