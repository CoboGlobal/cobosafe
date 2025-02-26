// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../helper/CoboSafeFactory.sol";
import "../../../interfaces/IVersion.sol";

interface ICoboSafe {
    function owner() external view returns (address);

    function safe() external view returns (address);

    function NAME() external view returns (bytes32);

    function authorizer() external view returns (address);
}

interface IRootAuthorizer {
    function getAllAuthorizers(bool, bytes32) external view returns (address[] memory);
}

contract TestCoboSafeFactory {
    CoboSafeFactory immutable factory;
    address constant SINGLETON = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552;

    bytes32 constant CUSTODY = "CoboCustody";

    constructor() {
        factory = new CoboSafeFactory();
    }

    function run(address[] memory owners, uint256 threshold) public {
        (address proxy, address coboSafe) = factory.createSafeAndCoboSafe(
            SINGLETON,
            block.timestamp,
            owners,
            threshold
        );

        IGnosisSafe safe = IGnosisSafe(proxy);
        checkOwnersAndThreshold(safe, owners, threshold);
        checkCoboSafeEnabeld(safe, coboSafe);
    }

    function checkOwnersAndThreshold(IGnosisSafe safe, address[] memory owners, uint256 threshold) internal view {
        require(safe.getOwners().length == owners.length, "owners length not match");
        for (uint256 i = 0; i < owners.length; i++) {
            require(safe.isOwner(owners[i]), "owners not match");
        }
        require(safe.getThreshold() == threshold, "threshold not match");
    }

    function checkCoboSafeEnabeld(IGnosisSafe safe, address _coboSafe) internal view {
        (address[] memory modules, ) = safe.getModulesPaginated(address(0x1), 10);
        require(modules.length == 1, "modules length not match");
        require(modules[0] == _coboSafe, "coboSafe not match");

        ICoboSafe coboSafe = ICoboSafe(modules[0]);
        require(coboSafe.owner() == address(safe), "coboSafe owner not match");
        require(coboSafe.safe() == address(safe), "coboSafe safe not match");
        require(coboSafe.NAME() == "CoboSafeAccount", "coboSafe name not match");
    }
}
