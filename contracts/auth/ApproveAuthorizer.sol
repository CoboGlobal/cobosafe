// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "./BaseApprovalAuthorizer.sol";

/// @title ApproveAuthorizer - Manages ERC20 approve permissons.
/// @author Cobo Safe Dev Team https://www.cobo.com/
/// @notice This checks token-spender pairs, no value is restricted.
contract ApproveAuthorizer is BaseApprovalAuthorizer {
    bytes32 public constant NAME = "ApproveAuthorizer";
    uint256 public constant VERSION = 1;
    bytes32 public constant override TYPE = AuthType.APPROVE;

    constructor(address _owner, address _caller) BaseSimpleAuthorizer(_owner, _caller) {}
}
