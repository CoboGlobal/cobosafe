// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../base/BaseACL.sol";

contract SampleFarmACL is BaseACL {
    bytes32 public constant NAME = "SampleFarmACL";
    uint256 public constant VERSION = 1;

    address public constant LP_TOKEN = 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16;
    address public constant MASTER_CHEF = 0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652;

    constructor(address _owner, address _caller) BaseACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](2);
        _contracts[0] = LP_TOKEN;
        _contracts[1] = MASTER_CHEF;
    }

    function approve(address spender, uint256 amount) external view onlyContract(LP_TOKEN) {
        require(spender == MASTER_CHEF, "approve: Invalid spender");
    }

    function deposit(uint256 _pid, uint256 _amount) external view onlyContract(MASTER_CHEF) {
        require(_pid == 3, "deposit: Pool is not allowed");
    }

    function withdraw(uint256 _pid, uint256 _amount) external view onlyContract(MASTER_CHEF) {
        require(_pid == 3, "withdraw: Pool is not allowed");
    }
}
