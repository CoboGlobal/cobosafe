// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../base/BaseSimpleAuthorizer.sol";

import "./CaclTypes.sol";
import "./Handlers.sol";
import "./AbiExprLib.sol";

contract CaclAuthorizer is BaseSimpleAuthorizer {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;
    using ExprLib for Expression;
    using RuleLib for Rule;
    using OpLib for uint8;
    using SolidityTypeLib for uint8;

    bytes32 public constant NAME = "CaclAuthorizer";
    bytes32 public constant override TYPE = "VM";
    uint256 public constant VERSION = 2;

    // Variables
    EnumerableSet.Bytes32Set internal varNames;
    mapping(bytes32 => address) internal variables;

    // Rules
    EnumerableSet.AddressSet internal rules;

    event VariableAdded(bytes32 indexed name);
    event VariableRemoved(bytes32 indexed name);
    event RuleAdded(address indexed id);
    event RuleRemoved(address indexed id);

    constructor(address _owner, address _caller) BaseSimpleAuthorizer(_owner, _caller) {
        // Ensure factory deployed.
        WriteOnce.store("test");
    }

    // For variables.
    function addVariable(bytes32 name, Expression calldata expr) external onlyOwner {
        varNames.add(name);
        variables[name] = expr.store();
        emit VariableAdded(name);
    }

    function removeVariable(bytes32 name) external onlyOwner {
        varNames.remove(name);
        delete variables[name];
        emit VariableRemoved(name);
    }

    function hasVariable(bytes32 name) public view returns (bool) {
        return varNames.contains(name);
    }

    function getVariable(bytes32 name) public view returns (Expression memory) {
        require(hasVariable(name), "Variable not exists");
        return ExprLib.load(variables[name]);
    }

    function getVariablesCount() external view returns (uint256) {
        return varNames.length();
    }

    // For rules.
    function addRule(Rule calldata rule) external onlyOwner returns (address id) {
        id = rule.store();
        rules.add(id);
        emit RuleAdded(id);
    }

    function removeRule(address id) external onlyOwner {
        require(rules.remove(id), "Rule not exists");
        emit RuleRemoved(id);
    }

    function removeRule(Rule calldata rule) external onlyOwner {
        address id = rule.getAddress();
        require(rules.remove(id), "Rule not exists");
        emit RuleRemoved(id);
    }

    function hasRule(address id) public view returns (bool) {
        return rules.contains(id);
    }

    function _getRule(address id) internal view returns (Rule memory rule) {
        rule = RuleLib.load(id);
    }

    function getRule(address id) public view returns (Rule memory rule) {
        require(hasRule(id), "Rule not exists");
        rule = _getRule(id);
    }

    function getRulesCount() external view returns (uint256) {
        return rules.length();
    }

    function getRules(uint256 start, uint256 end) external view returns (Rule[] memory ret) {
        uint256 count = rules.length();
        end = end > count ? count : end;
        ret = new Rule[](end - start);
        for (uint256 i = start; i < end; i++) {
            ret[i - start] = _getRule(rules.at(i));
        }
    }

    // For checks.

    function getRuleHint(TransactionData calldata transaction) public view returns (address) {
        uint256 count = rules.length();
        for (uint i = 0; i < count; i++) {
            address id = rules.at(i);
            if (runRule(transaction, id)) {
                return id;
            }
        }
        return address(0);
    }

    function _preExecCheck(
        TransactionData calldata transaction
    ) internal view override returns (AuthorizerReturnData memory authData) {
        address hintId;
        bool result;
        if (transaction.hint.length >= 32) {
            hintId = abi.decode(transaction.hint, (address));
        }
        if (hintId == address(0)) {
            hintId = getRuleHint(transaction);
            result = hintId != address(0);
        } else {
            result = runRule(transaction, hintId);
        }
        if (result) {
            return AuthorizerReturnData(AuthResult.SUCCESS, "", abi.encode(hintId));
        } else {
            return AuthorizerReturnData(AuthResult.FAILED, "No rules pass", "");
        }
    }

    function getReservedNamedValue(
        bytes32 name,
        TransactionData calldata transaction
    ) public view returns (bytes memory data) {
        if (name == "tx.sender") {
            return abi.encode(transaction.from);
        } else if (name == "tx.to") {
            return abi.encode(transaction.to);
        } else if (name == "tx.selector") {
            bytes4 selector = bytes4(transaction.data[0:4]);
            return abi.encode(selector);
        } else if (name == "tx.delegate") {
            return abi.encode(transaction.delegate);
        } else if (name == "tx.value") {
            return abi.encode(transaction.value);
        } else if (name == "block.timestamp") {
            return abi.encode(block.timestamp);
        } else {
            return data; // empty data
        }
    }

    function evalRef(TransactionData calldata transaction, bytes32 name) public view returns (bytes memory data) {
        data = getReservedNamedValue(name, transaction);
        if (data.length > 0) return data;
        Expression memory v = getVariable(name);
        require(v.data.length > 0, "name not found");
        return v.data;
    }

    function getRawData(
        TransactionData calldata transaction,
        Expression memory expr
    ) public view returns (bytes memory data) {
        uint8 op = expr.getOp();
        if (op == CONST) {
            return expr.data;
        } else if (op == VAR_NAME) {
            require(expr.data.length == 32, "Invalid name data");
            bytes32 name = abi.decode(expr.data, (bytes32));
            return evalRef(transaction, name);
        } else if (op == ABI_EXPR) {
            data = evalAbiExpr(transaction.data[4:], expr.data);
        } else {
            // Only boolean expression in this case.
            bool value = evalBoolExpr(transaction, expr);
            return abi.encode(value);
        }
    }

    function evalBoolExpr(TransactionData calldata transaction, Expression memory expr) public view returns (bool) {
        uint8 op = expr.getOp();
        uint8 typ = expr.getType();

        require(typ == BOOL, "Not bool expr");
        if (op.isDataOp()) {
            bytes memory data = getRawData(transaction, expr);
            require(data.length == 32, "Invalid bool data");
            return abi.decode(expr.data, (bool));
        } else if (op.isCmpOp()) {
            (Expression memory v1, Expression memory v2) = abi.decode(expr.data, (Expression, Expression));
            uint8 v1Type = v1.getType();
            uint8 v2Type = v2.getType();
            require(v1Type == v2Type, "Invalid opnds type for cmp");
            return handleCmpRawData(op, v1Type, getRawData(transaction, v1), getRawData(transaction, v2));
        } else if (op.isArrayOp()) {
            (Expression memory v1, Expression memory v2) = abi.decode(expr.data, (Expression, Expression));
            uint8 v1Type = v1.getType();
            uint8 v2Type = v2.getType();
            require(v2Type.isArray(), "V2 type not array in array op");
            require(v1Type.baseType() == v2Type.baseType(), "Type not match in array op");

            return handleArrayRawData(op, v1Type, getRawData(transaction, v1), getRawData(transaction, v2));
        } else if (op == AND) {
            Expression[] memory boolExprs = abi.decode(expr.data, (Expression[]));
            for (uint i = 0; i < boolExprs.length; ++i) {
                if (!evalBoolExpr(transaction, boolExprs[i])) return false; // Short circuit
            }
            return true;
        } else if (op == OR) {
            Expression[] memory boolExprs = abi.decode(expr.data, (Expression[]));
            for (uint i = 0; i < boolExprs.length; ++i) {
                if (evalBoolExpr(transaction, boolExprs[i])) return true; // Short circuit
            }
            return false;
        } else if (op == NOT) {
            Expression memory v1 = abi.decode(expr.data, (Expression));
            return !evalBoolExpr(transaction, v1);
        } else {
            revert("Invalid op met");
        }
    }

    function runRule(TransactionData calldata transaction, address id) public view returns (bool) {
        Rule memory rule = getRule(id);
        uint count = rule.exprs.length;
        if (count == 0) {
            // Rule not exist or is invalid.
            return false;
        }
        for (uint i = 0; i < count; i++) {
            if (!evalBoolExpr(transaction, rule.exprs[i])) {
                return false;
            }
        }
        // All exprs must pass.
        return true;
    }
}
