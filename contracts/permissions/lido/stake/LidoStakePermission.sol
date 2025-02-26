// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../BasePermission.sol";

contract LidoStakePermission is BasePermission {
    bytes32 public constant NAME = "LidoStakePermission";
    uint256 public constant VERSION = 1;
    uint256 public constant override flag = AuthFlags.SIMPLE_IMMUTABLE_MODE;

    address public constant stETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;

    constructor(address _owner, address _caller) BasePermission(address(0), address(0)) {}

    function contracts() public pure override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = stETH;
    }

    function submit(address _referral) external pure onlyContract(stETH) {
        // submit allowed
    }
}
