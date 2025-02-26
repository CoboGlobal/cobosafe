// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../BasePermission.sol";

contract LidoUnwraplPermission is BasePermission {
    bytes32 public constant NAME = "LidoUnwraplPermission";
    uint256 public constant VERSION = 1;
    uint256 public constant override flag = AuthFlags.SIMPLE_IMMUTABLE_MODE;

    address public constant wstETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;

    constructor(address _owner, address _caller) BasePermission(address(0), address(0)) {
        _addTokenSpender(wstETH, wstETH);

        /// @dev This permission is supposed to be permissionless and immutable
        ///      Do NOT use it in proxy mode.
        ///      If you have to use it in proxy mode, make sure you call
        ///      `addTokenSpenders([wstETH, wstETH])` before using it .
    }

    function contracts() public pure override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = wstETH;
    }

    // acl
    function unwrap(uint256 _wstETHAmount) external view nonPayable onlyContract(wstETH) {
        // unwrap allowed
    }
}
