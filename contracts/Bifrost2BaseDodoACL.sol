// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "./base/BaseACL.sol";

contract Bifrost2BaseDodoACL is BaseACL {
    bytes32 public constant NAME = "Bifrost2BaseDodoACL";
    uint256 public constant VERSION = 1;

    address public constant ADMIN = 0x30d1498DF98f41fAC8Ae89999f051708f90C5993;

    constructor(address _owner, address _caller) BaseACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](2);
        _contracts[0] = 0x61D907F4386b320bf2E61287576DA4207401c853;
        _contracts[1] = 0xA7E670C0f7C7a8F81029b1c56AeC71B83Bb28DC0;
    }

    function reset(
        address operator,
        uint256 newLpFeeRate,
        uint256 newI,
        uint256 newK,
        uint256 baseOutAmount,
        uint256 quoteOutAmount,
        uint256 minBaseReserve,
        uint256 minQuoteReserve
    ) 
        external view
    {
        require(operator == ADMIN, "approve: Invalid operator");
    }

    function tuneParameters(
        address operator,
        uint256 newLpFeeRate,
        uint256 newI,
        uint256 newK,
        uint256 minBaseReserve,
        uint256 minQuoteReserve
    ) 
        external view
    {
    }

    function tunePrice(
        address operator,
        uint256 newI,
        uint256 minBaseReserve,
        uint256 minQuoteReserve
    ) 
        external view 
    {
    }
}