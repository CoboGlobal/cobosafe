// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../BasePermission.sol";

contract LidoWrapPermission is BasePermission {
    bytes32 public constant NAME = "LidoWrapPermission";
    uint256 public constant VERSION = 1;

    address public constant wstETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
    address public constant stETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;

    bool public stETHEnabled;
    bool public ethEnabled;

    constructor(address _owner, address _caller) BasePermission(_owner, _caller) {}

    function contracts() public pure override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = wstETH;
    }

    // owner
    function setStETHEnabled(bool _stETHEnabled) external onlyOwner {
        stETHEnabled = _stETHEnabled;
        if (_stETHEnabled == true) {
            _addTokenSpender(stETH, wstETH);
        } else {
            _removeTokenSpender(stETH, wstETH);
        }
    }

    function setEthEnabled(bool _ethEnabled) external onlyOwner {
        ethEnabled = _ethEnabled;
    }

    // acl
    // warp stETH to wstETH
    function wrap(uint256 _stETHAmount) external view nonPayable onlyContract(wstETH) {
        require(stETHEnabled, "StETH not allowed");
    }

    // warp ETH to wstETH
    fallback() external override {
        TransactionData memory txn = _txn();
        if (txn.to == wstETH && txn.data.length == 0 && txn.value > 0) {
            // Contract call not allowed and token in white list.
            require(ethEnabled, "ETH not allowed");
        } else {
            revert(Errors.METHOD_NOT_ALLOW);
        }
    }
}
