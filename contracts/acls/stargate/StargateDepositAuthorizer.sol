// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../auth/FarmingBaseACL.sol";
import "./IStargateFactory.sol";
import "./StargateAddressUtils.sol";

contract StargateDepositAuthorizer is FarmingBaseACL {
    bytes32 public constant NAME = "StargateDepositAuthorizer";
    uint256 public constant VERSION = 1;

    address public immutable router;
    address public immutable stakingPool;
    address public immutable stargateFactory;

    constructor(address _owner, address _caller) FarmingBaseACL(_owner, _caller) {
        (stakingPool, router, stargateFactory) = getAddresses();
    }

    function addLiquidity(
        uint256 poolId,
        uint256, //_amountLD
        address _to
    ) external view onlyContract(router) {
        address liquidity_pool = IStargateFactory(stargateFactory).getPool(poolId);
        _checkAllowPoolAddress(liquidity_pool);
        _checkRecipient(_to);
    }

    function deposit(
        uint256 _pid,
        uint256 //amount
    ) public view onlyContract(stakingPool) {
        _checkAllowPoolId(_pid);
    }

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](2);
        _contracts[0] = router;
        _contracts[1] = stakingPool;
    }
}
