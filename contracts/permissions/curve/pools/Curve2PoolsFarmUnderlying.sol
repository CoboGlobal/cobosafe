// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "./CurveZapGauge.sol";

contract Curve2PoolsFarmUnderlying is CurveZapGauge {

    bytes32 public constant NAME = "Curve2PoolsFarmUnderlying";
    uint256 public constant VERSION = 1;
    uint256 public constant N_COINS = 2;

    constructor(address _owner, address _caller) CurveZapGauge(_owner, _caller) {}

    // acl
    function add_liquidity(uint256[N_COINS] memory amounts, uint256 min_mint_amount,bool _use_underlying) external view onlyContract(pool) {
        // deposit: pool.add_liquidity allowed
    }

    function add_liquidity(uint256[N_COINS] memory amounts, uint256 min_mint_amount) external view onlyContract(pool) {
        // deposit: pool.add_liquidity allowed
    }

    function remove_liquidity_one_coin(uint256 _token_amount,int128 i,uint256 min_amount,bool _use_underlying) external view onlyContract(pool) {
        // withdraw: pool.remove_liquidity_one_coin allowed
    }

    function remove_liquidity_one_coin(uint256 _token_amount,int128 i,uint256 min_amount) external view onlyContract(pool) {
        // withdraw: pool.remove_liquidity_one_coin allowed
    }

    function remove_liquidity(uint256 _amount,uint256[N_COINS] memory min_amounts,bool _use_underlying) external view onlyContract(pool) {
        // withdraw: pool.remove_liquidity allowed
    }

    function remove_liquidity(uint256 _amount,uint256[N_COINS] memory min_amounts) external view onlyContract(pool) {
        // withdraw: pool.remove_liquidity allowed
    }

    function remove_liquidity_imbalance(uint256[N_COINS] memory amounts,uint256 max_burn_amount,bool _use_underlying) external view onlyContract(pool) {
        // withdraw: pool.remove_liquidity allowed
    }

    function remove_liquidity_imbalance(uint256[N_COINS] memory amounts,uint256 max_burn_amount) external view onlyContract(pool) {
        // withdraw: pool.remove_liquidity allowed
    }

}
