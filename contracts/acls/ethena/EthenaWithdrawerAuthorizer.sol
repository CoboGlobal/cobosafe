// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../base/BaseSimpleACL.sol";

contract EthenaWithdrawerAuthorizer is BaseSimpleACL {
    bytes32 public constant NAME = "EthenaWithdrawerAuthorizer";
    uint256 public constant VERSION = 1;

    address public constant sUSDe = 0x9D39A5DE30e57443BfF2A8307A4256c8797A3497;

    constructor(address _owner, address _caller) BaseSimpleACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = sUSDe;
    }

    // acl

    function cooldownShares(uint256 shares) external view nonPayable onlyContract(sUSDe) {
        // pass
    }

    function unstake(address receiver) external view nonPayable onlyContract(sUSDe) {
        _checkRecipient(receiver);
    }
}
