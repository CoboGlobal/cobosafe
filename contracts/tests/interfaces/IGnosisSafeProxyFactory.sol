// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface IGnosisSafeProxyFactory {
    function createProxyWithNonce(address, bytes calldata, uint256) external returns (address);
}
