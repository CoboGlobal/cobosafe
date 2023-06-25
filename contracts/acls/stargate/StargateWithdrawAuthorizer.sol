// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../auth/FarmingBaseACL.sol";
import "./IStargateFactory.sol";
import "./StargateAddressUtils.sol";

contract StargateWithdrawAuthorizer is FarmingBaseACL {
    bytes32 public constant NAME = "StargateWithdrawAuthorizer";
    uint256 public constant VERSION = 1;

    address public immutable router;
    address public immutable stakingPool;
    address public immutable stargateFactory;

    constructor(address _owner, address _caller) FarmingBaseACL(_owner, _caller) {
        (stakingPool, router, stargateFactory) = getAddresses();
    }

    function instantRedeemLocal(
        uint16 _srcPoolId,
        uint256, //_amountLD
        address _to
    ) external view onlyContract(router) {
        address poolAddress = IStargateFactory(stargateFactory).getPool(_srcPoolId);
        _checkAllowPoolAddress(poolAddress);
        _checkRecipient(_to);
    }

    function withdraw(
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
