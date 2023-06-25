// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../auth/FarmingBaseACL.sol";

contract ConvexAuthorizer is FarmingBaseACL {
    bytes32 public constant NAME = "ConvexAuthorizer";
    uint256 public constant VERSION = 1;

    address public BOOSTER;
    address public BASE_REWARD_POOL;

    constructor(address _owner, address _caller) FarmingBaseACL(_owner, _caller) {}

    // Set functions.
    function setBooster(address _booster) external onlyOwner {
        BOOSTER = _booster;
    }

    function setRewardPool(address _baseRewardPool) external onlyOwner {
        BASE_REWARD_POOL = _baseRewardPool;
    }

    modifier onlyBooster() {
        _checkContract(BOOSTER);
        _;
    }

    modifier onlyBaseRewardPool() {
        _checkContract(BASE_REWARD_POOL);
        _;
    }

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](2);
        _contracts[0] = BOOSTER;
        _contracts[1] = BASE_REWARD_POOL;
    }

    // Checking functions.

    function depositAll(uint256 _pid, bool _stake) external view onlyBooster {
        _checkAllowPoolId(_pid);
    }

    function deposit(uint256 _pid, uint256 _amount, bool _stake) external view onlyBooster {
        _checkAllowPoolId(_pid);
    }

    function getReward(address _account, bool _claimExtras) external view onlyBaseRewardPool {
        _checkRecipient(_account);
    }
}
