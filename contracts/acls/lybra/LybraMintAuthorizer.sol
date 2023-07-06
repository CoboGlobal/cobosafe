// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../base/BaseACL.sol";

contract LybraMintAuthorizer is BaseACL {
    bytes32 public constant NAME = "LybraMintAuthorizer";
    uint256 public constant VERSION = 1;

    constructor(address _owner, address _caller) BaseACL(_owner, _caller) {}

    address public constant Lybra = 0x97de57eC338AB5d51557DA3434828C5DbFaDA371;

    function depositEtherToMint(address onBehalfOf, uint256 mintAmount) external view onlyContract(Lybra) {
        _checkRecipient(onBehalfOf);
    }

    function depositStETHToMint(
        address onBehalfOf,
        uint256 stETHamount,
        uint256 mintAmount
    ) external view onlyContract(Lybra) {
        _checkRecipient(onBehalfOf);
    }

    function mint(address onBehalfOf, uint256 amount) external view {
        _checkRecipient(onBehalfOf);
    }

    function becomeRedemptionProvider(bool _bool) external view {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = Lybra;
    }
}
