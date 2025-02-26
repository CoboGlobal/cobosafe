// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2 as console} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";

import {TargetAddressAuthorizer} from "../contracts/auth/TargetAddressAuthorizer.sol";
import {CaclAuthorizer} from "../contracts/cacl/CaclAuthorizer.sol";
import {ApprovalRateLimitAuthorizer} from "../contracts/auth/rate/ApprovalRateLimitAuthorizer.sol";
import {TransferRateLimitAuthorizer} from "../contracts/auth/rate/TransferRateLimitAuthorizer.sol";
import {ApprovalRecorder} from "../contracts/auth/rate/ApprovalRecorder.sol";
import {TransferRecorder} from "../contracts/auth/rate/TransferRecorder.sol";
import {CoboSafeAccount} from "../contracts/CoboSafeAccount.sol";
import {CoboPortalHelper} from "../contracts/helper/CoboPortalHelper.sol";
import {CoboSafeFactory} from "../contracts/helper/CoboSafeFactory.sol";

contract DeployScript is Script {
    using stdJson for string;

    address constant ZERO = address(0xc0b0);

    function setUp() public {}

    function getPath(string memory name) public view returns (string memory) {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/scripts_forge/deployments/", name, ".json");
        return path;
    }

    function addJson(string memory path, string memory key, string memory valueObject) public {
        string memory root = "root";
        if (vm.exists(path)) {
            root.serialize(vm.readFile(path));
        }
        root.serialize(key, valueObject).write(path);
    }

    function deployAll(string memory chain, string memory tag) public {
        vm.createSelectFork(chain);
        vm.startBroadcast();

        string memory json = "tag";
        string memory text;

        json.serialize("1_CoboPortalHelper", address(new CoboPortalHelper()));
        json.serialize("2_CoboSafeAccount", address(new CoboSafeAccount(ZERO)));
        json.serialize("3_CoboSafeFactory", address(new CoboSafeFactory()));
        json.serialize("4_TargetAddressAuthorizer", address(new TargetAddressAuthorizer(ZERO, ZERO)));
        json.serialize("5_ApprovalRateLimitAuthorizer", address(new ApprovalRateLimitAuthorizer(ZERO, ZERO)));
        text = json.serialize("6_TransferRateLimitAuthorizer", address(new TransferRateLimitAuthorizer(ZERO, ZERO)));
        // text = json.serialize("7_TransferRecorder", address(new TransferRecorder(ZERO, ZERO)));
        // json.serialize("8_ApprovalRecorder", address(new ApprovalRecorder(ZERO, ZERO)));
        // text = json.serialize("9_CaclAuthorizer", address(new CaclAuthorizer(ZERO, ZERO)));
        addJson(getPath(chain), tag, text);
    }
}
