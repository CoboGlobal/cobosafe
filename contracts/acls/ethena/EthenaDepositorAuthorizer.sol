// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../base/BaseSimpleACL.sol";

contract EthenaDepositorAuthorizer is BaseSimpleACL {
    bytes32 public constant NAME = "EthenaDepositorAuthorizer";
    uint256 public constant VERSION = 1;

    address public constant sUSDe = 0x9D39A5DE30e57443BfF2A8307A4256c8797A3497;

    constructor(address _owner, address _caller) BaseSimpleACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = sUSDe;
    }

    // acl
    function deposit(uint256 assets, address receiver) external view nonPayable onlyContract(sUSDe) {
        _checkRecipient(receiver);
    }
}
