// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../../base/BaseSimpleACL.sol";

abstract contract BaseCompoundAuthorizer is BaseSimpleACL {
    address public constant USDC = 0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA;
    address public constant cUSDbCv3 = 0x9c4ec768c28520B50860ea7a15bd7213a9fF58bf;

    address public constant cWETHv3 = 0x46e6b214b524310239732D51387075E0e70970bf;

    address public constant CometRewards = 0x123964802e6ABabBE1Bc9547D72Ef1B69B00A6b1;
    address public constant BaseBulker = 0x78D0677032A35c63D142a48A2037048871212a8C;

    /// @notice The action for supplying an asset to Comet
    bytes32 public constant ACTION_SUPPLY_ASSET = "ACTION_SUPPLY_ASSET";

    /// @notice The action for supplying a native asset (e.g. ETH on Ethereum mainnet) to Comet
    bytes32 public constant ACTION_SUPPLY_NATIVE_TOKEN = "ACTION_SUPPLY_NATIVE_TOKEN";

    /// @notice The action for transferring an asset within Comet
    bytes32 public constant ACTION_TRANSFER_ASSET = "ACTION_TRANSFER_ASSET";

    /// @notice The action for withdrawing an asset from Comet
    bytes32 public constant ACTION_WITHDRAW_ASSET = "ACTION_WITHDRAW_ASSET";

    /// @notice The action for withdrawing a native asset from Comet
    bytes32 public constant ACTION_WITHDRAW_NATIVE_TOKEN = "ACTION_WITHDRAW_NATIVE_TOKEN";

    /// @notice The action for claiming rewards from the Comet rewards contract
    bytes32 public constant ACTION_CLAIM_REWARD = "ACTION_CLAIM_REWARD";

    constructor(address _owner, address _caller) BaseSimpleACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](4);
        _contracts[0] = cUSDbCv3;
        _contracts[1] = cWETHv3;
        _contracts[2] = CometRewards;
        _contracts[3] = BaseBulker;
    }

    modifier onlyCometRewards() {
        _checkContract(CometRewards);
        _;
    }

    modifier onlyBaseBulker() {
        _checkContract(BaseBulker);
        _;
    }

    // internal
    function _checkClaimComet(address _comet) internal view {
        require(_comet == cWETHv3 || _comet == cUSDbCv3, "Invalid comet");
    }

    function _checkAsset(address _asset, address _allowedAsset) internal view {
        require(_asset == _allowedAsset, "Invalid asset");
    }

    function _checkComet(address _comet, address _allowedComet) internal view {
        require(_comet == _allowedComet, "Invalid comet");
    }

    function _checkRewards(address _rewards) internal view {
        require(_rewards == CometRewards, "Invalid rewards");
    }

    function _checkManager(address _manager) internal view {
        require(_manager == BaseBulker, "Invalid manager");
    }
}
