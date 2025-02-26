// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../base/BaseSimpleACL.sol";

contract AlienBaseClaimer is BaseSimpleACL {
    bytes32 public constant NAME = "AlienBaseClaimer";
    uint256 public constant VERSION = 1;

    address public constant DISTRIBUTOR = 0x52eaeCAC2402633d98b95213d0b473E069D86590;

    constructor(address _owner, address _caller) BaseSimpleACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = DISTRIBUTOR;
    }

    modifier onlyDistributor() {
        _checkContract(DISTRIBUTOR);
        _;
    }

    // DISTRIBUTOR acl
    function deposit(uint256 _pid, uint256 _amount) external view nonPayable onlyDistributor {
        // claim
        require(_amount == 0, "Invalid _amount");
    }
}
