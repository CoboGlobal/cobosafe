// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../auth/FarmingBaseACL.sol";

abstract contract AlienBaseDepositor is FarmingBaseACL {
    address public constant ROUTER = 0x8c1A3cF8f83074169FE5D7aD50B978e1cD6b37c7;
    address public constant DISTRIBUTOR = 0x52eaeCAC2402633d98b95213d0b473E069D86590;

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet farmPoolTokenWhitelist;

    //events
    event AddPoolTokenWhitelist(address indexed _poolToken, address indexed user);
    event RemovePoolTokenWhitelist(address indexed _poolToken, address indexed user);

    constructor(address _owner, address _caller) FarmingBaseACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](2);
        _contracts[0] = ROUTER;
        _contracts[1] = DISTRIBUTOR;
    }

    modifier onlyRouter() {
        _checkContract(ROUTER);
        _;
    }

    modifier onlyDistributor() {
        _checkContract(DISTRIBUTOR);
        _;
    }

    // owner
    function addPoolTokens(address[] calldata _poolTokens) external onlyOwner {
        for (uint256 i = 0; i < _poolTokens.length; i++) {
            if (farmPoolTokenWhitelist.add(_poolTokens[i])) {
                emit AddPoolTokenWhitelist(_poolTokens[i], msg.sender);
            }
        }
    }

    function removePoolTokens(address[] calldata _poolTokens) external onlyOwner {
        for (uint256 i = 0; i < _poolTokens.length; i++) {
            if (farmPoolTokenWhitelist.remove(_poolTokens[i])) {
                emit RemovePoolTokenWhitelist(_poolTokens[i], msg.sender);
            }
        }
    }

    function getPoolTokenWhiteList() external view returns (address[] memory) {
        return farmPoolTokenWhitelist.values();
    }

    function _checkAllowPoolToken(address _poolToken) internal view {
        require(farmPoolTokenWhitelist.contains(_poolToken), "pool token not allowed");
    }

    // DISTRIBUTOR acl
    function deposit(uint256 _pid, uint256 _amount) external view nonPayable onlyDistributor {
        // deposit & claim
        _checkAllowPoolId(_pid);
    }
}
