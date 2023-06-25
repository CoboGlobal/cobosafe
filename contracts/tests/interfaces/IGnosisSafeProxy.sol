// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface IGnosisSafeProxy {
    function getOwners() external returns (address[] memory);

    function getThreshold() external returns (uint256);

    function execTransaction(
        address,
        uint256,
        bytes calldata,
        uint8,
        uint256,
        uint256,
        uint256,
        address,
        address,
        bytes memory
    ) external returns (bool);

    function checkSignatures(bytes32, bytes memory, bytes memory) external;

    function enableModule(address) external;

    function isModuleEnabled(address) external returns (bool);
}
