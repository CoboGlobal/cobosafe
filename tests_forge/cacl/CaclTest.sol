// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../BaseTest.sol";
import "../../contracts/cacl/CaclAuthorizer.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CaclTest is BaseTest {
    CaclAuthorizer c;

    function setUp() public override {
        vm.selectFork(vm.createFork("mainnet"));
        c = new CaclAuthorizer(address(this), address(this));
    }

    function test_Variable() public {
        Expression memory expr = Expression(CONST, "");
        bytes32 name = "test";

        c.addVariable(name, expr);
        Expression memory expr2 = c.getVariable(name);
        assertEq(expr2.flag, expr.flag);

        assertTrue(c.hasVariable(name));
        c.removeVariable(name);
        assertFalse(c.hasVariable(name));

        vm.expectRevert(bytes("Variable not exists"));
        c.getVariable(name);
    }

    function test_Rule() public {
        Expression[] memory exprs = new Expression[](1);
        exprs[0] = Expression(CONST, "");
        Rule memory r = Rule(exprs);
        address id = c.addRule(r);
        assertEq(id, RuleLib.getAddress(r));

        address id2 = c.addRule(r);
        assertEq(id2, id);

        Rule[] memory rules = c.getRules(0, 1000);
        assertEq(rules.length, 1);
        assertEq(rules[0].exprs[0].flag, exprs[0].flag);

        assertTrue(c.hasRule(id));
        c.removeRule(id);

        vm.expectRevert(bytes("Rule not exists"));
        c.removeRule(id);

        assertFalse(c.hasRule(id));

        rules = c.getRules(0, 1000);
        assertEq(rules.length, 0);

        vm.expectRevert(bytes("Rule not exists"));
        c.getRule(id);
    }

    function test_RunRule() public {
        address TOKEN = address(0xfffff);
        bytes32 TRANSFER = hex"a9059cbb";
        Expression memory selector = ExprLib.makeConst(uint256(TRANSFER));
        Expression memory token = ExprLib.makeConst(TOKEN);

        Expression memory txSelector = ExprLib.makeName("tx.selector", UINT);
        Expression memory txTo = ExprLib.makeName("tx.to", ADDRESS);

        Rule memory rule;
        rule.exprs = new Expression[](2);
        rule.exprs[0] = Expression(ExprLib.packFlag(EQ, BOOL), abi.encode(txSelector, selector));
        rule.exprs[1] = Expression(ExprLib.packFlag(EQ, BOOL), abi.encode(txTo, token));
        c.addRule(rule);

        bytes memory data = abi.encodeCall(ERC20.transfer, (address(1), 2));
        TransactionData memory transaction = makeTx(address(this), TOKEN, 0, data);

        assertEq(c.getRawData(transaction, selector), c.getRawData(transaction, txSelector));

        assertTrue(checkPerm(address(c), TOKEN, 0, data));
        assertFalse(checkPerm(address(c), address(1), 0, data));
        assertFalse(checkPerm(address(c), TOKEN, 0, "TestData"));
    }
}
