// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../BaseDexPermission.sol";

contract CurveRouterPermission is BaseDexPermission {

    bytes32 public constant NAME = "CurveRouterPermission";
    uint256 public constant VERSION = 1;

    address public constant CurveRouter = 0xF0d4c12A5768D806021F80a262B4d39d26C58b8D;

    constructor(address _owner, address _caller) BaseDexPermission(_owner, _caller) {}

    function contracts() public pure override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = CurveRouter;
    }

    // acl
    function exchange(
        address[11] memory _route,
        uint256[5][5] memory _swap_params,
        uint256 _amount,
        uint256 _expected,
        address[5] memory _pools,
        address _receiver
    ) external view onlyContract(CurveRouter) {
        _checkRecipient(_receiver);
        _exchange(_route);
    }

    function exchange(
        address[11] memory _route,
        uint256[5][5] memory _swap_params,
        uint256 _amount,
        uint256 _expected,
        address[5] memory _pools
    ) external view onlyContract(CurveRouter) {
        _exchange(_route);
    }

    function exchange(
        address[11] memory _route,
        uint256[5][5] memory _swap_params,
        uint256 _amount,
        uint256 _expected,
        address _receiver
    ) external view onlyContract(CurveRouter) {
        _checkRecipient(_receiver);
        _exchange(_route);
    }

    // internal
    function _exchange(address[11] memory _route) internal view {
        address tokenIn = _route[0];
        address tokenOut;
        for (uint i = 1; i < 6; i++) {
            tokenOut = _route[i * 2];
            if ((i == 5) || (_route[(i * 2) + 1] == address(0))){
                break;
            }
        }
        _swapInOutTokenCheck(tokenIn, tokenOut);
        
    }

    function _addSwapInToken(address _token) internal override {
        _addTokenSpender(_token, CurveRouter);
        super._addSwapInToken(_token);
    }

    function _removeSwapInToken(address _token) internal override {
        _removeTokenSpender(_token, CurveRouter);
        super._removeSwapInToken(_token);
    }
}
