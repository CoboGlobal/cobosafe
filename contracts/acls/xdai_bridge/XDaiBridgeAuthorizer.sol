// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../base/BaseSimpleACL.sol";

contract XDaiBridgeAuthorizer is BaseSimpleACL {
    bytes32 public constant NAME = "XDaiBridgeAuthorizer";
    uint256 public constant VERSION = 1;

    address public constant HomeBridgeErcToNative = 0x7301CFA0e1756B71869E93d4e4Dca5c7d0eb0AA6;

    mapping(address => address) public safeToReceiver; // xdai safe address => receiver address on eth chain

    constructor(address _owner, address _caller) BaseSimpleACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](1);

        _contracts[0] = HomeBridgeErcToNative;
    }

    // ACL methods

    function relayTokens(address _receiver) external view onlyContract(HomeBridgeErcToNative) {
        // use 'require' to check the access
        // use '_checkRecipient' to check the recipient
        // all address parameters will be checked by '_checkRecipient', make sure the check is correct
        require(_receiver == safeToReceiver[_txn().from], "receiver not match");
    }

    function setReceiver(address _receiver) external onlyOwner {
        safeToReceiver[msg.sender] = _receiver;
    }

    function getReceiver() external view returns (address) {
        return safeToReceiver[owner];
    }
}
