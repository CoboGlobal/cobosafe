// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../BaseCompoundAuthorizer.sol";

contract BaseCompoundETHWithdrawer is BaseCompoundAuthorizer {
    bytes32 public constant NAME = "BaseCompoundETHWithdrawer"; //
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) BaseCompoundAuthorizer(_owner, _caller) {}

    modifier onlycWETHv3() {
        _checkContract(cWETHv3);
        _;
    }

    // acl

    function claim(address comet, address src, bool shouldAccrue) external view nonPayable onlyCometRewards {
        _checkComet(comet, cWETHv3);
        _checkRecipient(src);
    }

    function allow(address manager, bool isAllowed_) external view nonPayable onlycWETHv3 {
        _checkManager(manager);
    }

    function invoke(bytes32[] calldata actions, bytes[] calldata data) external view onlyBaseBulker {
        require(actions.length == data.length, "actions & data not match");
        for (uint i = 0; i < actions.length; ) {
            bytes32 action = actions[i];
            if (action == ACTION_WITHDRAW_NATIVE_TOKEN) {
                (address comet, address to, uint amount) = abi.decode(data[i], (address, address, uint));
                _checkComet(comet, cWETHv3);
                _checkRecipient(to);
            } else if (action == ACTION_CLAIM_REWARD) {
                (address comet, address rewards, address src, bool shouldAccrue) = abi.decode(
                    data[i],
                    (address, address, address, bool)
                );
                _checkClaimComet(comet);
                _checkRewards(rewards);
                _checkRecipient(src);
            } else {
                require(false, "Invalid action");
            }
            unchecked {
                i++;
            }
        }
    }
}
