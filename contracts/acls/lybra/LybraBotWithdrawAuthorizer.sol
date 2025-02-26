// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../base/BaseSimpleACL.sol";

contract LybraBotWithdrawAuthorizer is BaseSimpleACL {
    bytes32 public constant NAME = "LybraBotWithdrawAuthorizer";
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) BaseSimpleACL(_owner, _caller) {}

    address public constant Lybra = 0x97de57eC338AB5d51557DA3434828C5DbFaDA371;

    function burn(address onBehalfOf, uint256 amount) external view onlyContract(Lybra) {
        _checkRecipient(onBehalfOf);
    }

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = Lybra;
    }
}
