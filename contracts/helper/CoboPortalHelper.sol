// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import {IVersion} from "../../interfaces/IVersion.sol";
import {ArgusAccountHelper} from "./ArgusAccountHelper.sol";

import {TargetAddressAuthorizer} from "../auth/TargetAddressAuthorizer.sol";
import {BaseRateLimitAuthorizer} from "../auth/rate/BaseRateLimitAuthorizer.sol";
import {CaclAuthorizer} from "../cacl/CaclAuthorizer.sol";
import {Rule} from "../cacl/CaclTypes.sol";

contract CoboPortalHelper is ArgusAccountHelper {
    bytes32 public constant override NAME = "CoboPortalHelper";
    uint256 public constant override VERSION = 1;

    function createAndAddAuthorizerV2(AuthorizerParams calldata params) public returns (address _auth) {
        _auth = createAuthorizerV2(
            params.factory,
            params.coboSafeAddress,
            params.authorizerName,
            params.authorizerImplAddress,
            params.tag
        );
        addAuthorizerV2(params.coboSafeAddress, _auth, params.isDelegateCall, params.roles);
    }

    /// @dev TransferRate & ApprovalRate
    function addRateLimitAuthorizer(
        AuthorizerParams calldata params,
        address recorder,
        BaseRateLimitAuthorizer.TokenAccountAllowance[] calldata allowances
    ) external {
        address _auth = createAndAddAuthorizerV2(params);
        BaseRateLimitAuthorizer(_auth).setRecorder(recorder);
        BaseRateLimitAuthorizer(_auth).setTokenAccountAllowance(allowances);
    }

    function addTargetAddressAuthorizer(AuthorizerParams calldata params, address[] calldata _addresses) external {
        address _auth = createAndAddAuthorizerV2(params);
        TargetAddressAuthorizer(_auth).addTargetAddresses(_addresses);
    }

    function addCaclAuthorizer(AuthorizerParams calldata params, Rule[] calldata rules) external {
        address _auth = createAndAddAuthorizerV2(params);
        for (uint i = 0; i < rules.length; ++i) {
            CaclAuthorizer(_auth).addRule(rules[i]);
        }
    }
}
