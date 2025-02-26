// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

// See https://github.com/safe-global/safe-deployments/tree/main/src/assets/v1.3.0
function getSafeImplAddress() view returns (address) {
    uint id = block.chainid;
    if (id == 1) return 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552; // ETH
    if (id == 10) return 0x69f4D1788e39c87893C980c06EdF4b7f686e2938; // OP
    if (id == 56) return 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552; // BNB
    if (id == 100) return 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552; // Gnosis
    if (id == 137) return 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552; // Polygon
    if (id == 5000) return 0x69f4D1788e39c87893C980c06EdF4b7f686e2938; // Mantle
    if (id == 8453) return 0x69f4D1788e39c87893C980c06EdF4b7f686e2938; // Base
    if (id == 42161) return 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552; // ARB
    if (id == 43114) return 0x69f4D1788e39c87893C980c06EdF4b7f686e2938; // AVAX
    revert("SafeImplAddress not set");
}

function getSafeFactoryAddress() view returns (address) {
    uint id = block.chainid;
    if (id == 1) return 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2; // ETH
    if (id == 10) return 0xC22834581EbC8527d974F8a1c97E1bEA4EF910BC; // OP
    if (id == 56) return 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2; // BNB
    if (id == 100) return 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2; // Gnosis
    if (id == 137) return 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2; // Polygon
    if (id == 5000) return 0xC22834581EbC8527d974F8a1c97E1bEA4EF910BC; // Mantle
    if (id == 8453) return 0xC22834581EbC8527d974F8a1c97E1bEA4EF910BC; // Base
    if (id == 42161) return 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2; // ARB
    if (id == 43114) return 0xC22834581EbC8527d974F8a1c97E1bEA4EF910BC; // AVAX
    revert("SafeFactoryAddress not set");
}

function getFallbackHandlerAddress() view returns (address) {
    uint id = block.chainid;
    if (id == 1) return 0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4; // ETH
    if (id == 10) return 0x017062a1dE2FE6b99BE3d9d37841FeD19F573804; // OP
    if (id == 56) return 0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4; // BNB
    if (id == 100) return 0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4; // Gnosis
    if (id == 137) return 0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4; // Polygon
    if (id == 5000) return 0x017062a1dE2FE6b99BE3d9d37841FeD19F573804; // Mantle
    if (id == 8453) return 0x017062a1dE2FE6b99BE3d9d37841FeD19F573804; // Base
    if (id == 42161) return 0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4; // ARB
    if (id == 43114) return 0x017062a1dE2FE6b99BE3d9d37841FeD19F573804; // AVAX
    revert("SafeFactoryAddress not set");
}

function getCoboFactoryAddress() view returns (address) {
    uint id = block.chainid;
    if (id == 5000 || id == 8453) return 0x589b92136f97c26CA8BB907a2e3208580422E847; // Mantle & Base
    return 0xC0B00000e19D71fA50a9BB1fcaC2eC92fac9549C;
}
