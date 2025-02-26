// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../BasePermission.sol";

contract LidoWithdrawalPermission is BasePermission {
    bytes32 public constant NAME = "LidoWithdrawalPermission";
    uint256 public constant VERSION = 1;

    address public constant unstETH = 0x889edC2eDab5f40e902b864aD4d7AdE8E412F9B1;
    address public constant stETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    address public constant wstETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;

    bool public stETHEnabled;
    bool public wstETHEnabled;

    constructor(address _owner, address _caller) BasePermission(_owner, _caller) {}

    function contracts() public pure override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = unstETH;
    }

    // owner
    function setStETHEnabled(bool _stETHEnabled) external onlyOwner {
        stETHEnabled = _stETHEnabled;

        if (_stETHEnabled == true) {
            _addTokenSpender(stETH, unstETH);
        } else {
            _removeTokenSpender(stETH, unstETH);
        }
    }

    function setWstETHEnabled(bool _wstETHEnabled) external onlyOwner {
        wstETHEnabled = _wstETHEnabled;
        if (_wstETHEnabled == true) {
            _addTokenSpender(wstETH, unstETH);
        } else {
            _removeTokenSpender(wstETH, unstETH);
        }
    }

    // acl
    function requestWithdrawals(
        uint256[] calldata _amounts,
        address _owner
    ) external view nonPayable onlyContract(unstETH) {
        require(stETHEnabled, "requestWithdrawals not allowed");

        // check owner
        _checkRecipient(_owner);
    }

    function requestWithdrawalsWstETH(
        uint256[] calldata _amounts,
        address _owner
    ) external view nonPayable onlyContract(unstETH) {
        require(wstETHEnabled, "requestWithdrawalsWstETH not allowed");

        // check owner
        _checkRecipient(_owner);
    }

    function claimWithdrawals(
        uint256[] calldata _requestIds,
        uint256[] calldata _hints
    ) external view nonPayable onlyContract(unstETH) {
        // claimWithdrawals allowed
    }
}
