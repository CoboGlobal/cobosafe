// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../base/BaseSimpleACL.sol";

contract EqbPendleaUSDCClaimer is BaseSimpleACL {
    bytes32 public constant NAME = "EqbPendleaUSDCClaimer";
    uint256 public constant VERSION = 1;

    address public constant PendleRouterV3 = 0x00000000005BBB0EF59571E58418F9a4357b68A0;
    address public constant EqbZap = 0xc7517f481Cc0a645e63f870830A4B2e580421e32;

    constructor(address _owner, address _caller) BaseSimpleACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](2);
        _contracts[0] = PendleRouterV3;
        _contracts[1] = EqbZap;
    }

    // claim
    function claimRewards(uint256[] calldata _pids) external view nonPayable onlyContract(EqbZap) {
        // pass
    }

    function redeemDueInterestAndRewards(
        address user,
        address[] calldata sys,
        address[] calldata yts,
        address[] calldata markets
    ) external view nonPayable onlyContract(PendleRouterV3) {
        _checkRecipient(user);
    }
}
