// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../BasePermission.sol";
import "../../BaseTokenSetter.sol";

contract UniswapV2LiquidityPermission is BaseTokenSetter, BasePermission {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 public constant NAME = "UniswapV2LiquidityPermission";
    uint256 public constant VERSION = 1;

    address public constant UniswapV2Router02 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant UniswapV2Factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    constructor(address _owner, address _caller) BasePermission(_owner, _caller) {}

    function contracts() public pure override returns (address[] memory _contracts) {
        _contracts = new address[](2);
        _contracts[0] = UniswapV2Router02;
        _contracts[1] = UniswapV2Factory;
    }

    // acl

    // UniswapV2Factory
    function createPair(address tokenA, address tokenB) external view nonPayable onlyContract(UniswapV2Factory) {
        // createPair allowed
    }

    //UniswapV2Router02
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external view nonPayable onlyContract(UniswapV2Router02) {
        _checkRecipient(to);
        _checkAllowedToken(tokenA);
        _checkAllowedToken(tokenB);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external view nonPayable onlyContract(UniswapV2Router02) {
        _checkRecipient(to);
        _checkAllowedToken(tokenA);
        _checkAllowedToken(tokenB);
    }

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external view onlyContract(UniswapV2Router02) {
        _checkRecipient(to);
        _checkAllowedToken(token);
    }

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external view nonPayable onlyContract(UniswapV2Router02) {
        _checkRecipient(to);
        _checkAllowedToken(token);
    }

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external view nonPayable onlyContract(UniswapV2Router02) {
        _checkRecipient(to);
        _checkAllowedToken(token);
    }

    function _addAllowedToken(address _token) internal override {
        _addTokenSpender(_token, UniswapV2Router02);
        super._addAllowedToken(_token);
    }

    function _removeAllowedToken(address _token) internal override {
        _removeTokenSpender(_token, UniswapV2Router02);
        super._removeAllowedToken(_token);
    }
}
