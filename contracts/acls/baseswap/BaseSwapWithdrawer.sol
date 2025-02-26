// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../base/BaseSimpleACL.sol";

abstract contract BaseSwapWithdrawer is BaseSimpleACL {
    address public constant ROUTER = 0x327Df1E6de05895d2ab08513aaDD9313Fe505d86;
    address public POOL;

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet farmPoolTokenWhitelist;

    //events
    event AddPoolTokenWhitelist(address indexed _poolToken, address indexed user);
    event RemovePoolTokenWhitelist(address indexed _poolToken, address indexed user);

    constructor(address _owner, address _caller) BaseSimpleACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](2);
        _contracts[0] = ROUTER;
        _contracts[1] = POOL;
    }

    modifier onlyRouter() {
        _checkContract(ROUTER);
        _;
    }

    modifier onlyPool() {
        _checkContract(POOL);
        _;
    }

    // owner
    function setPool(address _pool) external onlyOwner {
        POOL = _pool;
    }

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

    // ROUTER acl
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external view nonPayable onlyRouter {
        _checkAllowPoolToken(tokenA);
        _checkAllowPoolToken(tokenB);
        _checkRecipient(to);
    }

    // Pool acl
    function withdrawFromPosition(uint256 tokenId, uint256 amountToWithdraw) external view nonPayable onlyPool {}
}
