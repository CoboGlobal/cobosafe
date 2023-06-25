// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../interfaces/IRoleManager.sol";

contract DummyRoleManager is IRoleManager {
    /// @dev Return the address itself in bytes32 as its role.
    function getRoles(address delegate) external pure returns (bytes32[] memory) {
        bytes32[] memory roles = new bytes32[](1);
        roles[0] = bytes32(uint256(uint160(delegate)));
        return roles;
    }

    function hasRole(address delegate, bytes32 role) external pure returns (bool) {
        return true;
    }
}
