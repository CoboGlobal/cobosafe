// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "../contracts/base/BaseAuthorizer.sol";
import {CoboSafeFactory, IGnosisSafe} from "../contracts/helper/CoboSafeFactory.sol";
import {CoboSafeAccount} from "../contracts/CoboSafeAccount.sol";
import {FlatRoleManager} from "../contracts/role/FlatRoleManager.sol";
import {ArgusRootAuthorizer} from "../contracts/auth/ArgusRootAuthorizer.sol";
import "./TestConstants.sol";

contract BaseTest is Test {
    address immutable owner = address(this);
    address constant delegate = address(0x1000002);
    bytes32 constant DEFAULT_ROLE = "DEFAULT";

    CoboSafeFactory factory;
    IGnosisSafe safe;
    CoboSafeAccount cobosafe;

    function setUp() public virtual {
        vm.deal(owner, 100 ether);
        vm.deal(delegate, 100 ether);
    }

    function initFork(string memory chain) public {
        vm.selectFork(vm.createFork(chain));

        factory = new CoboSafeFactory();
        address[] memory owners = new address[](1);
        owners[0] = owner;

        bytes32[] memory roles = new bytes32[](1);
        roles[0] = DEFAULT_ROLE;

        (address _safe, address _cobosafe) = factory.createSafeAndCoboSafe(getSafeImplAddress(), 0, owners, 1);
        safe = IGnosisSafe(_safe);
        cobosafe = CoboSafeAccount(payable(_cobosafe));

        vm.deal(_safe, 100 ether);
        console.log("safe:", _safe);
        console.log("cobosafe:", _cobosafe);

        vm.startPrank(_safe);
        cobosafe.addDelegate(delegate);
        FlatRoleManager roleManager = FlatRoleManager(cobosafe.roleManager());
        address[] memory delegates = new address[](1);
        delegates[0] = delegate;
        roleManager.grantRoles(roles, delegates);
        vm.stopPrank();
    }

    function makeTx(
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) public pure returns (TransactionData memory transaction) {
        transaction.from = from;
        transaction.to = to;
        transaction.value = value;
        transaction.data = data;
    }

    function checkPerm(address perm, address to, uint256 value, bytes memory data) public returns (bool) {
        TransactionData memory transaction = makeTx(owner, to, value, data);
        AuthorizerReturnData memory authData = BaseAuthorizer(perm).preExecCheck(transaction);
        return authData.result == AuthResult.SUCCESS;
    }

    function checkAllowed(address perm, address to, uint256 value, bytes memory data) public returns (bool) {
        require(checkPerm(perm, to, value, data), "checkAllowed failed");
    }

    function addAuthorizer(address authorizer, bytes32 role) public {
        vm.startPrank(address(safe));
        ArgusRootAuthorizer root = ArgusRootAuthorizer(cobosafe.authorizer());
        root.addAuthorizer(false, role, authorizer);
        vm.stopPrank();
    }

    function addAuthorizer(address authorizer) public {
        addAuthorizer(authorizer, DEFAULT_ROLE);
    }

    function coboSafeCall(
        address _delegate,
        address to,
        uint256 value,
        bytes memory data
    ) public returns (bool success, bytes memory retData) {
        vm.prank(_delegate);
        TransactionResult memory result = cobosafe.execTransaction(
            CallData({flag: 0, to: to, value: value, data: data, hint: "", extra: ""})
        );
        success = result.success;
        retData = result.data;
    }

    function coboSafeCall(
        address to,
        uint256 value,
        bytes memory data
    ) public returns (bool success, bytes memory retData) {
        return coboSafeCall(delegate, to, value, data);
    }

    function runPostExecProcess(address perm, address to, uint256 value, bytes memory data) public returns (bool) {
        TransactionData memory transaction = makeTx(owner, to, value, data);
        TransactionResult memory transactionResult = TransactionResult(true, data, data);
        BaseAuthorizer(perm).postExecProcess(transaction, transactionResult);
        return true;
    }
}
