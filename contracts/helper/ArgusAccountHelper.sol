// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../interfaces/IVersion.sol";
import "../CoboFactory.sol";
import "./ArgusAuthorizerHelper.sol";

contract ArgusAccountHelper is ArgusAuthorizerHelper, IVersion {
    function NAME() external pure virtual returns (bytes32) {
        return "ArgusAccountHelper";
    }

    function VERSION() external pure virtual returns (uint256) {
        return 3;
    }

    event ArgusInitialized(address indexed cobosafe, address indexed safe, address indexed factory);

    function initArgus(CoboFactory factory, bytes32 coboSafeAccountSalt) external {
        address safe = address(this);
        // 1. Create and enable CoboSafe.
        CoboSafeAccount coboSafe = CoboSafeAccount(
            payable(factory.create2AndRecord("CoboSafeAccount", coboSafeAccountSalt))
        );
        coboSafe.initialize(safe);
        IGnosisSafe(safe).enableModule(address(coboSafe));
        // 2. Set roleManager.
        FlatRoleManager roleManager = FlatRoleManager(factory.create("FlatRoleManager"));
        roleManager.initialize(safe);
        coboSafe.setRoleManager(address(roleManager));
        // 3. Set authorizer
        BaseAuthorizer authorizer = BaseAuthorizer(factory.create("ArgusRootAuthorizer"));
        authorizer.initialize(safe, address(coboSafe), address(coboSafe));
        coboSafe.setAuthorizer(address(authorizer));

        emit ArgusInitialized(address(coboSafe), safe, address(factory));
    }

    event ArgusUpgraded(address indexed oldCoboSafe, address indexed newCoboSafe, address indexed factory);

    function upgradeArgus(
        CoboFactory factory,
        bytes32 newSalt,
        address oldCoboSafeAddress,
        address prevModule
    ) external {
        IGnosisSafe safe = IGnosisSafe(address(this));

        // 1. Disable old CoboSafe.
        safe.disableModule(prevModule, oldCoboSafeAddress);

        // 2. Create and enable new CoboSafe.
        CoboSafeAccount newCoboSafe = CoboSafeAccount(payable(factory.create2AndRecord("CoboSafeAccount", newSalt)));
        IGnosisSafe(safe).enableModule(address(newCoboSafe));

        // 3. Migrate data to new CoboSafe.
        CoboSafeAccount oldCoboSafe = CoboSafeAccount(payable(oldCoboSafeAddress));
        newCoboSafe.initialize(address(safe), oldCoboSafe.roleManager(), oldCoboSafe.authorizer());
        newCoboSafe.addDelegates(oldCoboSafe.getAllDelegates());

        // 4. Update authorizer's data.
        BaseAuthorizer authorizer = BaseAuthorizer(oldCoboSafe.authorizer());
        authorizer.setCaller(address(newCoboSafe));
        authorizer.setAccount(address(newCoboSafe));

        emit ArgusUpgraded(oldCoboSafeAddress, address(newCoboSafe), address(factory));
    }

    function b32(string calldata stringName) internal returns (bytes32 bytes32Name) {
        return bytes32(bytes(stringName));
    }

    function b32(string[] calldata stringNames) internal returns (bytes32[] memory bytes32Names) {
        bytes32Names = new bytes32[](stringNames.length);
        for (uint256 i = 0; i < stringNames.length; ++i) {
            bytes32Names[i] = b32(stringNames[i]);
        }
    }

    function grantRoles(address coboSafeAddress, bytes32[] memory roles, address[] calldata delegates) public {
        // 1. Add delegates to CoboSafe.
        CoboSafeAccount coboSafe = CoboSafeAccount(payable(coboSafeAddress));
        coboSafe.addDelegates(delegates);
        // 2. Grant role/delegate in roleManager.
        FlatRoleManager roleManager = FlatRoleManager(coboSafe.roleManager());
        roleManager.grantRoles(roles, delegates);
    }

    // `string` type is more friendly for human-reading.
    function grantRolesV2(address coboSafeAddress, string[] calldata roles, address[] calldata delegates) external {
        grantRoles(coboSafeAddress, b32(roles), delegates);
    }

    function revokeRoles(address coboSafeAddress, bytes32[] memory roles, address[] calldata delegates) public {
        // 1. Revoke role/delegate for roleManager.
        CoboSafeAccount coboSafe = CoboSafeAccount(payable(coboSafeAddress));
        FlatRoleManager roleManager = FlatRoleManager(coboSafe.roleManager());
        roleManager.revokeRoles(roles, delegates);
    }

    function revokeRolesV2(address coboSafeAddress, string[] calldata roles, address[] calldata delegates) external {
        revokeRoles(coboSafeAddress, b32(roles), delegates);
    }

    function createAuthorizer(
        CoboFactory factory,
        address coboSafeAddress,
        bytes32 authorizerName,
        bytes32 tag
    ) public returns (address) {
        address safe = address(this);
        // 1. Get ArgusRootAuthorizer.
        CoboSafeAccount coboSafe = CoboSafeAccount(payable(coboSafeAddress));
        ArgusRootAuthorizer rootAuthorizer = ArgusRootAuthorizer(coboSafe.authorizer());
        // 2. Create authorizer and add to root authorizer set
        BaseAuthorizer authorizer = BaseAuthorizer(factory.create2(authorizerName, tag));
        authorizer.initialize(safe, address(rootAuthorizer));
        authorizer.setTag(tag);
        return address(authorizer);
    }

    function createAuthorizerV2(
        CoboFactory factory,
        address coboSafeAddress,
        string calldata authorizerName,
        address authorizerImplAddress,
        string calldata tag
    ) public returns (address) {
        bytes32 _authorizerName = b32(authorizerName);
        require(factory.getLatestImplementation(_authorizerName) == authorizerImplAddress, "Impl is out-of-date");
        return createAuthorizer(factory, coboSafeAddress, _authorizerName, b32(tag));
    }

    function addAuthorizer(
        address coboSafeAddress,
        address authorizerAddress,
        bool isDelegateCall,
        bytes32[] memory roles
    ) public {
        // 1. Get ArgusRootAuthorizer.
        CoboSafeAccount coboSafe = CoboSafeAccount(payable(coboSafeAddress));
        ArgusRootAuthorizer rootAuthorizer = ArgusRootAuthorizer(coboSafe.authorizer());
        // 2. Add authorizer to root authorizer set
        for (uint256 i = 0; i < roles.length; i++) {
            rootAuthorizer.addAuthorizer(isDelegateCall, roles[i], authorizerAddress);
        }
    }

    function addAuthorizerV2(
        address coboSafeAddress,
        address authorizerAddress,
        bool isDelegateCall,
        string[] calldata roles
    ) public {
        addAuthorizer(coboSafeAddress, authorizerAddress, isDelegateCall, b32(roles));
    }

    function createAndAddAuthorizer(
        CoboFactory factory,
        address coboSafeAddress,
        string calldata authorizerName,
        address authorizerImplAddress,
        string calldata tag,
        bool isDelegateCall,
        string[] calldata roles
    ) external {
        address authorizerAddress = createAuthorizerV2(
            factory,
            coboSafeAddress,
            authorizerName,
            authorizerImplAddress,
            tag
        );
        addAuthorizerV2(coboSafeAddress, authorizerAddress, isDelegateCall, roles);
    }

    function removeAuthorizer(
        address coboSafeAddress,
        address authorizerAddress,
        bool isDelegateCall,
        bytes32[] memory roles
    ) public {
        // 1. Get ArgusRootAuthorizer.
        CoboSafeAccount coboSafe = CoboSafeAccount(payable(coboSafeAddress));
        ArgusRootAuthorizer rootAuthorizer = ArgusRootAuthorizer(coboSafe.authorizer());
        // 2. Remove authorizer from root authorizer set
        for (uint256 i = 0; i < roles.length; i++) {
            rootAuthorizer.removeAuthorizer(isDelegateCall, roles[i], authorizerAddress);
        }
    }

    function removeAuthorizerV2(
        address coboSafeAddress,
        address authorizerAddress,
        bool isDelegateCall,
        string[] calldata roles
    ) external {
        removeAuthorizer(coboSafeAddress, authorizerAddress, isDelegateCall, b32(roles));
    }

    function addFuncAuthorizer(
        CoboFactory factory,
        address coboSafeAddress,
        bool isDelegateCall,
        bytes32[] memory roles,
        address[] calldata _contracts,
        string[][] calldata funcLists,
        bytes32 tag
    ) public {
        // 1. create FuncAuthorizer
        address authorizerAddress = createAuthorizer(factory, coboSafeAddress, "FuncAuthorizer", tag);
        // 2. Set params
        setFuncAuthorizerParams(authorizerAddress, _contracts, funcLists);
        // 3. Add authorizer to root authorizer set
        addAuthorizer(coboSafeAddress, authorizerAddress, isDelegateCall, roles);
    }

    struct AuthorizerParams {
        CoboFactory factory;
        address coboSafeAddress;
        string authorizerName;
        address authorizerImplAddress;
        bool isDelegateCall;
        string[] roles;
        string tag;
    }

    function addFuncAuthorizerV2(
        AuthorizerParams calldata params,
        address[] calldata _contracts,
        string[][] calldata funcLists
    ) external {
        // 1. create FuncAuthorizer
        address authorizerAddress = createAuthorizerV2(
            params.factory,
            params.coboSafeAddress,
            params.authorizerName,
            params.authorizerImplAddress,
            params.tag
        );
        // 2. Set params
        setFuncAuthorizerParams(authorizerAddress, _contracts, funcLists);
        // 3. Add authorizer to root authorizer set
        addAuthorizerV2(params.coboSafeAddress, authorizerAddress, params.isDelegateCall, params.roles);
    }

    function addTransferAuthorizer(
        CoboFactory factory,
        address coboSafeAddress,
        bool isDelegateCall,
        bytes32[] memory roles,
        TransferAuthorizer.TokenReceiver[] calldata tokenReceivers,
        bytes32 tag
    ) public {
        // 1. create TransferAuthorizer
        address authorizerAddress = createAuthorizer(factory, coboSafeAddress, "TransferAuthorizer", tag);
        // 2. Set params
        setTransferAuthorizerParams(authorizerAddress, tokenReceivers);
        // 3. Add authorizer to root authorizer set
        addAuthorizer(coboSafeAddress, authorizerAddress, isDelegateCall, roles);
    }

    function addTransferAuthorizerV2(
        AuthorizerParams calldata params,
        TransferAuthorizer.TokenReceiver[] calldata tokenReceivers
    ) external {
        // 1. create TransferAuthorizer
        address authorizerAddress = createAuthorizerV2(
            params.factory,
            params.coboSafeAddress,
            params.authorizerName,
            params.authorizerImplAddress,
            params.tag
        );
        // 2. Set params
        setTransferAuthorizerParams(authorizerAddress, tokenReceivers);
        // 3. Add authorizer to root authorizer set
        addAuthorizerV2(params.coboSafeAddress, authorizerAddress, params.isDelegateCall, params.roles);
    }

    function addDexAuthorizer(
        CoboFactory factory,
        address coboSafeAddress,
        bytes32 dexAuthorizerName,
        bool isDelegateCall,
        bytes32[] memory roles,
        address[] calldata _swapInTokens,
        address[] calldata _swapOutTokens,
        bytes32 tag
    ) public {
        // 1. create DexAuthorizer
        address authorizerAddress = createAuthorizer(factory, coboSafeAddress, dexAuthorizerName, tag);
        // 2. Set params
        setDexAuthorizerParams(authorizerAddress, _swapInTokens, _swapOutTokens);
        // 3. Add authorizer to root authorizer set
        addAuthorizer(coboSafeAddress, authorizerAddress, isDelegateCall, roles);
    }

    function addDexAuthorizerV2(
        AuthorizerParams calldata params,
        address[] calldata _swapInTokens,
        address[] calldata _swapOutTokens
    ) external {
        // 1. create DexAuthorizer
        address authorizerAddress = createAuthorizerV2(
            params.factory,
            params.coboSafeAddress,
            params.authorizerName,
            params.authorizerImplAddress,
            params.tag
        );
        // 2. Set params
        setDexAuthorizerParams(authorizerAddress, _swapInTokens, _swapOutTokens);
        // 3. Add authorizer to root authorizer set
        addAuthorizerV2(params.coboSafeAddress, authorizerAddress, params.isDelegateCall, params.roles);
    }

    function addApproveAuthorizer(
        CoboFactory factory,
        address coboSafeAddress,
        bool isDelegateCall,
        bytes32[] memory roles,
        ApproveAuthorizer.TokenSpender[] calldata tokenSpenders,
        bytes32 tag
    ) public {
        // 1. create ApproveAuthorizer
        address authorizerAddress = createAuthorizer(factory, coboSafeAddress, "ApproveAuthorizer", tag);
        // 2. Set params
        setApproveAuthorizerParams(authorizerAddress, tokenSpenders);
        // 3. Add authorizer to root authorizer set
        addAuthorizer(coboSafeAddress, authorizerAddress, isDelegateCall, roles);
    }

    function addApproveAuthorizerV2(
        AuthorizerParams calldata params,
        ApproveAuthorizer.TokenSpender[] calldata tokenSpenders
    ) external {
        // 1. create ApproveAuthorizer
        address authorizerAddress = createAuthorizerV2(
            params.factory,
            params.coboSafeAddress,
            params.authorizerName,
            params.authorizerImplAddress,
            params.tag
        );
        // 2. Set params
        setApproveAuthorizerParams(authorizerAddress, tokenSpenders);
        // 3. Add authorizer to root authorizer set
        addAuthorizerV2(params.coboSafeAddress, authorizerAddress, params.isDelegateCall, params.roles);
    }
}
