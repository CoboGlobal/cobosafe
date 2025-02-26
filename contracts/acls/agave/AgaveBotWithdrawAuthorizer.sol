// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../base/BaseSimpleACL.sol";

contract AgaveBotWithdrawAuthorizer is BaseSimpleACL {
    bytes32 public constant NAME = "AgaveBotWithdrawAuthorizer";
    uint256 public constant VERSION = 1;

    address public constant SavingsXDaiAdapter = 0xD499b51fcFc66bd31248ef4b28d656d67E591A94;

    constructor(address _owner, address _caller) BaseSimpleACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](1);

        _contracts[0] = SavingsXDaiAdapter;
    }

    // ACL methods

    function redeemAllXDAI(address receiver) external view onlyContract(SavingsXDaiAdapter) {
        // use 'require' to check the access
        // use '_checkRecipient' to check the recipient
        // all address parameters will be checked by '_checkRecipient', make sure the check is correct

        _checkRecipient(receiver);
    }
}
