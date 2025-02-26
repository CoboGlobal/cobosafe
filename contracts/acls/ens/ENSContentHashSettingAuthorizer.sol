// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../base/BaseSimpleACL.sol";

contract ENSContentHashSettingAuthorizer is BaseSimpleACL {
    bytes32 public constant NAME = "ENSContentHashSettingAuthorizer";
    uint256 public constant VERSION = 1;

    address public constant ENS_PUBLIC_RESOLVER = 0x231b0Ee14048e9dCcD1d247744d114a4EB5E8E63;

    modifier onlySelf() {
        require(msg.sender == address(this));
        _;
    }

    constructor(address _owner, address _caller) BaseSimpleACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = ENS_PUBLIC_RESOLVER;
    }

    function multicall(bytes[] calldata data) external view onlyContract(ENS_PUBLIC_RESOLVER) {
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, ) = address(this).staticcall(data[i]);
            require(success, "Setting not allowed");
        }
    }

    function setContenthash(bytes32 node, bytes calldata hash) external view onlySelf {}
}
