// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../auth/DEXBaseACL.sol";

contract AerodromeSwapAuthorizer is DEXBaseACL {
    bytes32 public constant NAME = "AerodromeSwapAuthorizer";
    uint256 public constant VERSION = 1;

    address public constant ROUTER = 0xcF77a3Ba9A5CA399B7c97c74d54e5b1Beb874E43;

    struct Route {
        address from;
        address to;
        bool stable;
        address factory;
    }

    constructor(address _owner, address _caller) DEXBaseACL(_owner, _caller) {}

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] calldata routes,
        address to,
        uint256 deadline
    ) external nonPayable onlyContract(ROUTER) {
        address tokenIn = routes[0].from;
        address tokenOut = routes[routes.length - 1].to;
        _swapInOutTokenCheck(tokenIn, tokenOut);
        _checkRecipient(to);
    }

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] calldata routes,
        address to,
        uint256 deadline
    ) external onlyContract(ROUTER) {
        address tokenIn = routes[0].from;
        address tokenOut = routes[routes.length - 1].to;
        _swapInOutTokenCheck(tokenIn, tokenOut);
        _checkRecipient(to);
    }

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = ROUTER;
    }
}
