// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../Constants.sol";

address constant x = address(0);

library AaveV2Addresses {
    // https://docs.aave.com/developers/v/2.0/deployed-contracts/deployed-contracts

    // TODO: Add addresses for other chains.
    function Pool() internal view returns (address) {
        uint256 id = block.chainid;
        if (id == ChainIds.ETH) return 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
        if (id == ChainIds.OP) return x;
        if (id == ChainIds.BSC) return x;
        if (id == ChainIds.MATIC) return x;
        if (id == ChainIds.ARB) return x;
        if (id == ChainIds.AVAX) return x;
        revert("Unsupported chain");
    }

    function WETHGateway() internal view returns (address) {
        uint256 id = block.chainid;
        if (id == ChainIds.ETH) return 0xEFFC18fC3b7eb8E676dac549E0c693ad50D1Ce31;
        if (id == ChainIds.OP) return x;
        if (id == ChainIds.BSC) return x;
        if (id == ChainIds.MATIC) return x;
        if (id == ChainIds.ARB) return x;
        if (id == ChainIds.AVAX) return x;
        revert("Unsupported chain");
    }

    function aWETH() internal view returns (address) {
        uint256 id = block.chainid;
        if (id == ChainIds.ETH) return 0x030bA81f1c18d280636F32af80b9AAd02Cf0854e;
        if (id == ChainIds.OP) return x;
        if (id == ChainIds.BSC) return x;
        if (id == ChainIds.MATIC) return x;
        if (id == ChainIds.ARB) return x;
        if (id == ChainIds.AVAX) return x;
        revert("Unsupported chain");
    }

    function variableDebtWETH() internal view returns (address) {
        uint256 id = block.chainid;
        if (id == ChainIds.ETH) return 0xF63B34710400CAd3e044cFfDcAb00a0f32E33eCf;
        if (id == ChainIds.OP) return x;
        if (id == ChainIds.BSC) return x;
        if (id == ChainIds.MATIC) return x;
        if (id == ChainIds.ARB) return x;
        if (id == ChainIds.AVAX) return x;
        revert("Unsupported chain");
    }

    function stableDebtWETH() internal view returns (address) {
        uint256 id = block.chainid;
        if (id == ChainIds.ETH) return 0x4e977830ba4bd783C0BB7F15d3e243f73FF57121;
        if (id == ChainIds.OP) return x;
        if (id == ChainIds.BSC) return x;
        if (id == ChainIds.MATIC) return x;
        if (id == ChainIds.ARB) return x;
        if (id == ChainIds.AVAX) return x;
        revert("Unsupported chain");
    }
}

library AaveV3Addresses {
    // https://docs.aave.com/developers/deployed-contracts/v3-mainnet
    function Pool() internal view returns (address) {
        uint256 id = block.chainid;
        if (id == ChainIds.ETH) return 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;
        if (id == ChainIds.OP) return x;
        if (id == ChainIds.BSC) return x;
        if (id == ChainIds.MATIC) return x;
        if (id == ChainIds.ARB) return x;
        if (id == ChainIds.AVAX) return x;
        revert("Unsupported chain");
    }

    function WETHGateway() internal view returns (address) {
        uint256 id = block.chainid;
        if (id == ChainIds.ETH) return 0xD322A49006FC828F9B5B37Ab215F99B4E5caB19C;
        if (id == ChainIds.OP) return x;
        if (id == ChainIds.BSC) return x;
        if (id == ChainIds.MATIC) return x;
        if (id == ChainIds.ARB) return x;
        if (id == ChainIds.AVAX) return x;
        revert("Unsupported chain");
    }

    function aWETH() internal view returns (address) {
        uint256 id = block.chainid;
        if (id == ChainIds.ETH) return 0x4d5F47FA6A74757f35C14fD3a6Ef8E3C9BC514E8;
        if (id == ChainIds.OP) return x;
        if (id == ChainIds.BSC) return x;
        if (id == ChainIds.MATIC) return x;
        if (id == ChainIds.ARB) return x;
        if (id == ChainIds.AVAX) return x;
        revert("Unsupported chain");
    }

    function variableDebtWETH() internal view returns (address) {
        uint256 id = block.chainid;
        if (id == ChainIds.ETH) return 0xeA51d7853EEFb32b6ee06b1C12E6dcCA88Be0fFE;
        if (id == ChainIds.OP) return x;
        if (id == ChainIds.BSC) return x;
        if (id == ChainIds.MATIC) return x;
        if (id == ChainIds.ARB) return x;
        if (id == ChainIds.AVAX) return x;
        revert("Unsupported chain");
    }

    function stableDebtWETH() internal view returns (address) {
        uint256 id = block.chainid;
        if (id == ChainIds.ETH) return 0x102633152313C81cD80419b6EcF66d14Ad68949A;
        if (id == ChainIds.OP) return x;
        if (id == ChainIds.BSC) return x;
        if (id == ChainIds.MATIC) return x;
        if (id == ChainIds.ARB) return x;
        if (id == ChainIds.AVAX) return x;
        revert("Unsupported chain");
    }
}
