// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../BaseDexPermission.sol";

contract UniswapV2SwapPermission is BaseDexPermission {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 public constant NAME = "UniswapV2SwapPermission";
    uint256 public constant VERSION = 1;

    address public constant UniswapV2Router02 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    constructor(address _owner, address _caller) BaseDexPermission(_owner, _caller) {}

    function contracts() public pure override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = UniswapV2Router02;
    }

    // acl
    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external view onlyContract(UniswapV2Router02) {
        _commonDexCheck(to, path[0], path[path.length - 1]);
    }

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external view onlyContract(UniswapV2Router02) {
        _commonDexCheck(to, path[0], path[path.length - 1]);
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external view onlyContract(UniswapV2Router02) {
        _commonDexCheck(to, path[0], path[path.length - 1]);
    }

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external view nonPayable onlyContract(UniswapV2Router02) {
        _commonDexCheck(to, path[0], path[path.length - 1]);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external view nonPayable onlyContract(UniswapV2Router02) {
        _commonDexCheck(to, path[0], path[path.length - 1]);
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external view nonPayable onlyContract(UniswapV2Router02) {
        _commonDexCheck(to, path[0], path[path.length - 1]);
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external view nonPayable onlyContract(UniswapV2Router02) {
        _commonDexCheck(to, path[0], path[path.length - 1]);
    }

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external view nonPayable onlyContract(UniswapV2Router02) {
        _commonDexCheck(to, path[0], path[path.length - 1]);
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external view nonPayable onlyContract(UniswapV2Router02) {
        _commonDexCheck(to, path[0], path[path.length - 1]);
    }

    // internal

    function _addSwapInToken(address _token) internal override {
        _addTokenSpender(_token, UniswapV2Router02);
        super._addSwapInToken(_token);
    }

    function _removeSwapInToken(address _token) internal override {
        _removeTokenSpender(_token, UniswapV2Router02);
        super._removeSwapInToken(_token);
    }
}
