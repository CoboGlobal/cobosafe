// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../BasePermission.sol";

contract CurvePoolSwapUnderlying is BasePermission {

    bytes32 public constant NAME = "CurvePoolSwapUnderlying";
    uint256 public constant VERSION = 1;

    address public Pool;

    constructor(address _owner, address _caller) BasePermission(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = Pool;
    }

    // owner
    function setPool(address _pool) external onlyOwner {
        require(_pool != address(0),"zero address not allowed");
        Pool = _pool;
    }

    // acl
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external view onlyContract(Pool) {
        // exchange allowed
    }

    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external view onlyContract(Pool) {
        // exchange allowed
    }
}
