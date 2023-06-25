// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../auth/DEXBaseACL.sol";
import "../ACLUtils.sol";

contract PancakeSwapAuthorizer is DEXBaseACL {
    bytes32 public constant NAME = "PancakeSwapAuthorizer";
    uint256 public constant VERSION = 1;

    address public constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public constant SMART_ROUTER = 0x2f22e47CA7C5e07F77785f616cEeE80c5E84127C;
    address public immutable WETH = getWrappedTokenAddress();

    constructor(address _owner, address _caller) DEXBaseACL(_owner, _caller) {}

    modifier onlyV2Router() {
        _checkContract(ROUTER);
        _;
    }

    modifier onlySmartRouter() {
        _checkContract(SMART_ROUTER);
        _;
    }

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](2);
        _contracts[0] = ROUTER;
        _contracts[1] = SMART_ROUTER;
    }

    function _getToken(address _token) internal view returns (address) {
        return _token == ZERO_ADDRESS ? ETH_ADDRESS : _token;
    }

    // Checking functions.
    function _commonCheck(address to, address[] memory tokenPath) internal view {
        _commonCheck(to, _getToken(tokenPath[0]), _getToken(tokenPath[tokenPath.length - 1]));
    }

    function _commonCheck(address to, address tokenIn, address tokenOut) internal view {
        _checkRecipient(to);
        _swapInOutTokenCheck(tokenIn, tokenOut);
    }

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external view onlyV2Router {
        _commonCheck(to, ETH_ADDRESS, _getToken(path[path.length - 1]));
    }

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external view onlyV2Router {
        _commonCheck(to, ETH_ADDRESS, _getToken(path[path.length - 1]));
    }

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external view onlyV2Router {
        _commonCheck(to, _getToken(path[0]), ETH_ADDRESS);
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external view onlyV2Router {
        _commonCheck(to, path);
    }

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external view onlyV2Router {
        _commonCheck(to, _getToken(path[0]), ETH_ADDRESS);
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external view onlyV2Router {
        _commonCheck(to, path);
    }

    enum FLAG {
        STABLE_SWAP,
        V2_EXACT_IN
    }

    function swap(
        address srcToken,
        address dstToken,
        uint256 amount,
        uint256 minReturn,
        FLAG flag
    ) external view onlySmartRouter {
        address inToken = address(srcToken);
        address outToken = address(dstToken);
        _swapInOutTokenCheck(_getToken(inToken), _getToken(outToken));
    }

    function swapMulti(
        address[] calldata tokens,
        uint256 amount,
        uint256 minReturn,
        FLAG[] calldata flagss
    ) external view onlySmartRouter {
        address inToken = address(tokens[0]);
        address outToken = address(tokens[tokens.length - 1]);
        _swapInOutTokenCheck(_getToken(inToken), _getToken(outToken));
    }
}
