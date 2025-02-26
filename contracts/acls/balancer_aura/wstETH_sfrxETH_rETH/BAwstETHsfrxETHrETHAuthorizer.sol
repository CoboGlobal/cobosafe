// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../../auth/FarmingBaseACL.sol";

interface IAsset {
    // solhint-disable-previous-line no-empty-blocks
}

interface IVault {
    enum SwapKind {
        GIVEN_IN,
        GIVEN_OUT
    }

    struct BatchSwapStep {
        bytes32 poolId;
        uint256 assetInIndex;
        uint256 assetOutIndex;
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    struct JoinPoolRequest {
        IAsset[] assets;
        uint256[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

    struct ExitPoolRequest {
        IAsset[] assets;
        uint256[] minAmountsOut;
        bytes userData;
        bool toInternalBalance;
    }
}

contract BAwstETHsfrxETHrETHAuthorizer is FarmingBaseACL {
    bytes32 public constant NAME = "BAwstETHsfrxETHrETHAuthorizer";
    uint256 public constant VERSION = 1;

    address public VAULT_ADDRESS;
    address public BOOSTER_ADDRESS;
    address public RELAYER_ADDRESS;

    using EnumerableSet for EnumerableSet.Bytes32Set;
    EnumerableSet.Bytes32Set balancerFarmPoolIdWhitelist;

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet swapInTokenWhitelist;
    EnumerableSet.AddressSet swapOutTokenWhitelist;

    event SwapInTokenAdded(address indexed token);
    event SwapInTokenRemoved(address indexed token);
    event SwapOutTokenAdded(address indexed token);
    event SwapOutTokenRemoved(address indexed token);

    struct SwapInToken {
        address token;
        bool tokenStatus;
    }

    struct SwapOutToken {
        address token;
        bool tokenStatus;
    }

    enum SwapKind {
        GIVEN_IN,
        GIVEN_OUT
    }

    struct BatchSwapStep {
        bytes32 poolId;
        uint256 assetInIndex;
        uint256 assetOutIndex;
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        IAsset assetIn;
        IAsset assetOut;
        uint256 amount;
        bytes userData;
    }

    struct OutputReference {
        uint256 index;
        uint256 key;
    }

    event AddPoolIdWhitelist(bytes32 indexed _poolId, address indexed user);
    event RemovePoolIdWhitelist(bytes32 indexed _poolId, address indexed user);

    constructor(address _owner, address _caller) FarmingBaseACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](3);
        _contracts[0] = BOOSTER_ADDRESS;
        _contracts[1] = VAULT_ADDRESS;
        _contracts[2] = RELAYER_ADDRESS;
    }

    // Set
    function setBooster(address _booster) external onlyOwner {
        BOOSTER_ADDRESS = _booster;
    }

    function setVault(address _vault) external onlyOwner {
        VAULT_ADDRESS = _vault;
    }

    function setRelayer(address _relayer) external onlyOwner {
        RELAYER_ADDRESS = _relayer;
    }

    function addBalancerPoolIds(bytes32[] calldata _poolIds) external onlyOwner {
        for (uint256 i = 0; i < _poolIds.length; i++) {
            if (balancerFarmPoolIdWhitelist.add(_poolIds[i])) {
                emit AddPoolIdWhitelist(_poolIds[i], msg.sender);
            }
        }
    }

    function removeBalancerPoolIds(bytes32[] calldata _poolIds) external onlyOwner {
        for (uint256 i = 0; i < _poolIds.length; i++) {
            if (balancerFarmPoolIdWhitelist.remove(_poolIds[i])) {
                emit RemovePoolIdWhitelist(_poolIds[i], msg.sender);
            }
        }
    }

    function addSwapInTokens(address[] calldata _tokens) external onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            if (swapInTokenWhitelist.add(token)) {
                emit SwapInTokenAdded(token);
            }
        }
    }

    function removeSwapInTokens(address[] calldata _tokens) external onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            if (swapInTokenWhitelist.remove(token)) {
                emit SwapInTokenRemoved(token);
            }
        }
    }

    function addSwapOutTokens(address[] calldata _tokens) external onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            if (swapOutTokenWhitelist.add(token)) {
                emit SwapOutTokenAdded(token);
            }
        }
    }

    function removeSwapOutTokens(address[] calldata _tokens) external onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            if (swapOutTokenWhitelist.remove(token)) {
                emit SwapOutTokenRemoved(token);
            }
        }
    }

    // View
    function getBalancerPoolIdWhiteList() external view returns (bytes32[] memory) {
        return balancerFarmPoolIdWhitelist.values();
    }

    function hasSwapInToken(address _token) public view returns (bool) {
        return swapInTokenWhitelist.contains(_token);
    }

    function getSwapInTokens() external view returns (address[] memory tokens) {
        return swapInTokenWhitelist.values();
    }

    function hasSwapOutToken(address _token) public view returns (bool) {
        return swapOutTokenWhitelist.contains(_token);
    }

    function getSwapOutTokens() external view returns (address[] memory tokens) {
        return swapOutTokenWhitelist.values();
    }

    // Acl

    // Balancer

    function batchSwap(
        SwapKind kind,
        BatchSwapStep[] memory swaps,
        IAsset[] memory assets,
        FundManagement memory funds,
        int256[] memory limits,
        uint256 deadline
    ) external view onlyContract(VAULT_ADDRESS) {
        _batchSwapCheck(funds.sender, funds.recipient, swaps, assets);
    }

    function swap(
        SingleSwap memory singleSwap,
        FundManagement memory funds,
        uint256 limit,
        uint256 deadline
    ) external view onlyContract(VAULT_ADDRESS) {
        _checkRecipient(funds.sender);
        _checkRecipient(funds.recipient);
        _swapInOutTokenCheck(address(singleSwap.assetIn), address(singleSwap.assetOut));
    }

    function setRelayerApproval(
        address sender,
        address relayer,
        bool approved
    ) external view nonPayable onlyContract(VAULT_ADDRESS) {
        // Vault
        _checkRecipient(sender);
        require(relayer == RELAYER_ADDRESS, "Not relayer address");
    }

    // BalancerRelayer
    //  multicall

    function multicall(bytes[] calldata data) external view onlyContract(RELAYER_ADDRESS) {
        TransactionData memory txn = _txn();
        bytes memory txnData = abi.encode(txn);

        for (uint256 i = 0; i < data.length; i++) {
            bytes memory callDataSize = abi.encode(data[i].length);
            (bool success, bytes memory return_data) = address(this).staticcall(
                abi.encodePacked(data[i], txnData, callDataSize)
            );
            require(success, "Failed in multicall");
        }
    }

    enum PoolKind {
        WEIGHTED,
        LEGACY_STABLE,
        COMPOSABLE_STABLE,
        COMPOSABLE_STABLE_V2
    }

    function joinPool(
        bytes32 poolId,
        PoolKind kind,
        address sender,
        address recipient,
        IVault.JoinPoolRequest memory request,
        uint256 value,
        uint256 outputReference
    ) external view onlyContract(RELAYER_ADDRESS) {
        _poolRelayerCheck(poolId, sender, recipient);
    }

    function exitPool(
        bytes32 poolId,
        PoolKind kind,
        address sender,
        address payable recipient,
        IVault.ExitPoolRequest memory request,
        OutputReference[] calldata outputReferences
    ) external view onlyContract(RELAYER_ADDRESS) {
        _poolRelayerCheck(poolId, sender, recipient);
    }

    // Aura
    function deposit(
        uint256 _pid,
        uint256 _amount,
        bool _stake
    ) external view nonPayable onlyContract(BOOSTER_ADDRESS) {
        _checkAllowPoolId(_pid);
        require(_stake == true, "_stake must be true");
    }

    // Internal

    function _batchSwapCheck(
        address _sender,
        address _recipient,
        BatchSwapStep[] memory _swaps,
        IAsset[] memory _assets
    ) internal view {
        _checkRecipient(_sender);
        _checkRecipient(_recipient);
        _batchSwapTokensCheck(_swaps, _assets);
    }

    function _batchSwapTokensCheck(BatchSwapStep[] memory _swaps, IAsset[] memory _assets) internal view {
        BatchSwapStep memory batchSwapStep;

        bool[] memory isInToken = new bool[](_assets.length);
        bool[] memory isOutToken = new bool[](_assets.length);

        for (uint256 i = 0; i < _swaps.length; ++i) {
            batchSwapStep = _swaps[i];

            if (isOutToken[batchSwapStep.assetInIndex]) {
                // if have A -> B and we got B -> C, clear B's flag.
                isOutToken[batchSwapStep.assetInIndex] = false;
                isInToken[batchSwapStep.assetInIndex] = false;
            } else {
                isInToken[batchSwapStep.assetInIndex] = true;
            }

            isOutToken[batchSwapStep.assetOutIndex] = true;
        }

        for (uint256 i = 0; i < _assets.length; ++i) {
            if (isInToken[i]) _swapInTokenCheck(address(_assets[i]));
            if (isOutToken[i]) _swapOutTokenCheck(address(_assets[i]));
        }
    }

    function _poolRelayerCheck(bytes32 _poolId, address _sender, address _recipient) internal view {
        _checkBalancerAllowPoolId(_poolId);
        _checkRecipient(_sender);
        _checkRecipient(_recipient);
    }

    function _checkBalancerAllowPoolId(bytes32 _poolId) internal view {
        require(balancerFarmPoolIdWhitelist.contains(_poolId), "pool id not allowed");
    }

    function _swapInTokenCheck(address _token) internal view {
        require(hasSwapInToken(_token), "In token not allowed");
    }

    function _swapOutTokenCheck(address _token) internal view {
        require(hasSwapOutToken(_token), "Out token not allowed");
    }

    function _swapInOutTokenCheck(address _inToken, address _outToken) internal view {
        _swapInTokenCheck(_inToken);
        _swapOutTokenCheck(_outToken);
    }
}
