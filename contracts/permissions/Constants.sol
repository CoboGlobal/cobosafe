// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

library ChainIds {
    uint256 constant ETH = 1;
    uint256 constant OP = 10;
    uint256 constant BSC = 56;
    uint256 constant GNOSIS = 100;
    uint256 constant MATIC = 137;
    uint256 constant MANTLE = 5000;
    uint256 constant BASE = 8453;
    uint256 constant ARB = 42161;
    uint256 constant AVAX = 43114;
}

library Addresses {
    address constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address constant ZERO = address(0);

    function WrappedToken() internal view returns (address) {
        uint256 id = block.chainid;
        if (id == ChainIds.ETH) return 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        if (id == ChainIds.OP) return 0x4200000000000000000000000000000000000006;
        if (id == ChainIds.BSC) return 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        if (id == ChainIds.MATIC) return 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
        if (id == ChainIds.ARB) return 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
        if (id == ChainIds.AVAX) return 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;
        revert("Unsupported chain");
    }
}
