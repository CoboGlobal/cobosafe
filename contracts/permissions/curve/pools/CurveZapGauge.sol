// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../BasePermission.sol";
import "../../BaseTokenSetter.sol";

abstract contract CurveZapGauge is BaseTokenSetter, BasePermission {

    // bytes32 public constant NAME = "CurveZapGauge";
    // uint256 public constant VERSION = 1;

    address public constant ZAP = 0x271fbE8aB7f1fB262f81C77Ea5303F03DA9d3d6A;
    address public constant TOKENMINTER = 0xd061D61a4d941c39E5453435B6345Dc261C2fcE0;

    address public pool;
    address public lptoken;
    address public gauge;

    constructor(address _owner, address _caller) BasePermission(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](3);
        _contracts[0] = pool;
        _contracts[1] = gauge;
        _contracts[2] = ZAP;
    }

    // owner
    function setPool(address _pool) external onlyOwner {
        require(_pool != address(0), "zero address not allowed");
        pool = _pool;
    }

    function setLptoken(address _lptoken) external onlyOwner {
        require(_lptoken != address(0), "zero address not allowed");
        lptoken = _lptoken;
    }

    function setGauge(address _gauge) external onlyOwner {
        require(_gauge != address(0), "zero address not allowed");
        gauge = _gauge;
    }

    // acl
    function deposit(uint256 value) external view onlyContract(gauge) {
        // stake: gauge.deposit allowed
    }

    function set_approve_deposit(address addr, bool can_deposit) external view onlyContract(gauge) {
        // deposit & stake: gauge.set_approve_deposit
        require(addr == ZAP, "addr not allowed");
    }

    function deposit_and_stake(
        address _deposit,
        address lp_token,
        address _gauge,
        uint256 n_coins,
        address[5] memory coins,
        uint256[5] memory amounts,
        uint256 min_mint_amount,
        bool use_underlying,
        address _pool
    ) external view onlyContract(ZAP) {
        // deposit & stake: ZAP.deposit_and_stake
        require(pool == address(0) || _pool == pool,"_pool not allowed");
        _check_deposit_and_stake(_deposit,lp_token,_gauge,n_coins,coins);
    }

    function deposit_and_stake(
        address _deposit,
        address lp_token,
        address _gauge,
        uint256 n_coins,
        address[5] memory coins,
        uint256[5] memory amounts,
        uint256 min_mint_amount,
        bool use_underlying
    ) external view onlyContract(ZAP) {
        // deposit & stake: ZAP.deposit_and_stake
       _check_deposit_and_stake(_deposit,lp_token,_gauge,n_coins,coins);
    }

    function withdraw(uint256 value) external view onlyContract(gauge) {
        // unstake: gauge.withdraw allowed
    }

    function mint(address gauge_addr) external view onlyContract(TOKENMINTER) {
        // Claim Rewards: gauge.withdraw allowed
    }

    function mint_many(address[8] memory gauge_addrs) external view onlyContract(TOKENMINTER) {
        // Claim Rewards: gauge.withdraw allowed
    }

    // internal

    function _check_deposit_and_stake(
        address _deposit,
        address lp_token,
        address _gauge,
        uint256 n_coins,
        address[5] memory coins
        ) internal view {
        require(_deposit == pool && pool != address(0),"deposit not allowed");
        require(lp_token == lptoken && lptoken != address(0),"lp_token not allowed");
        require(_gauge == gauge && gauge != address(0),"gauge not allowed");
        for (uint i = 0; i < n_coins; i++) {
            _checkAllowedToken(coins[i]);
        }
    }


    function _addAllowedToken(address _token) internal override {
        // deposit: approve token to pool
        // stake: approve lptoken to gauge
        // deposit & stake : approve token to ZAP

        if (_token == lptoken) {
            _addTokenSpender(_token, gauge);
        } else {
            _addTokenSpender(_token, pool);
            _addTokenSpender(_token, ZAP);
        }

        super._addAllowedToken(_token);
    }

    function _removeAllowedToken(address _token) internal override {
        // deposit: approve token to pool
        // stake: approve lptoken to gauge
        // deposit & stake : approve token to ZAP

        if (_token == lptoken) {
            _removeTokenSpender(_token, gauge);
        } else {
            _removeTokenSpender(_token, pool);
            _removeTokenSpender(_token, ZAP);
        }
        super._removeAllowedToken(_token);
    }
}
