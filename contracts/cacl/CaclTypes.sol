// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../base/BaseSimpleAuthorizer.sol";
import "./WriteOnce.sol";

// Solidity type
uint8 constant BYTES = 0x1; // bytes, string
uint8 constant UINT = 0x2; // uint8~uint256, bytes1~bytes32
uint8 constant INT = 0x3; // int8~int256
uint8 constant BOOL = 0x4;
uint8 constant ADDRESS = 0x5;

uint8 constant ARRAY = 0x10; // array bit.
uint8 constant BYTES_ARRAY = BYTES | ARRAY;
uint8 constant UINT_ARRAY = UINT | ARRAY;
uint8 constant INT_ARRAY = INT | ARRAY;
uint8 constant BOOL_ARRAY = BOOL | ARRAY;
uint8 constant ADDRESS_ARRAY = ADDRESS | ARRAY;

library SolidityTypeLib {
    function isArray(uint8 typ) internal pure returns (bool) {
        return typ & ARRAY == ARRAY;
    }

    function baseType(uint8 typ) internal pure returns (uint8) {
        return typ & 0xf;
    }
}

// Expression op
uint8 constant CONST = 0x1; // type + bytes.
uint8 constant VAR_NAME = 0x2; // type + name
uint8 constant ABI_EXPR = 0x3; // type + ABI expression

uint8 constant EQ = 0x10; // v1 == v2
uint8 constant NE = 0x11; // v1 != v2
uint8 constant GT = 0x12; // v1 > v2
uint8 constant GE = 0x13; // v1 >= v2
uint8 constant LT = 0x14; // v1 < v2
uint8 constant LE = 0x15; // v1 <= v2

uint8 constant IN = 0x20; // v1 in [...]
uint8 constant NOT_IN = 0x21; // v1 not in [...]

uint8 constant AND = 0x31; // v1 and v2
uint8 constant OR = 0x32; // v1 or v2

uint8 constant NOT = 0x41; // not v1

library OpLib {
    function isDataOp(uint8 op) internal pure returns (bool) {
        return op >= CONST && op <= ABI_EXPR;
    }

    function isCmpOp(uint8 op) internal pure returns (bool) {
        return op >= EQ && op <= LE;
    }

    function isArrayOp(uint8 op) internal pure returns (bool) {
        return op >= IN && op <= NOT_IN;
    }
}

struct Expression {
    uint256 flag;
    bytes data;
}

library ExprLib {
    function getOp(Expression memory expr) internal pure returns (uint8 op) {
        op = uint8(expr.flag & 0xff);
    }

    function getType(Expression memory expr) internal pure returns (uint8 typ) {
        typ = uint8((expr.flag >> 8) & 0xff);
    }

    function getAddress(Expression memory expr) internal view returns (address) {
        return WriteOnce.getPointer(abi.encode(expr));
    }

    function store(Expression memory expr) internal returns (address) {
        return WriteOnce.store(abi.encode(expr));
    }

    function load(address id) internal view returns (Expression memory expr) {
        expr = abi.decode(WriteOnce.load(id), (Expression));
    }

    function packFlag(uint8 op, uint8 typ) internal pure returns (uint256 flag) {
        flag |= uint256(op);
        flag |= uint256(typ) << 8;
    }

    function makeConst(uint256 value) internal pure returns (Expression memory expr) {
        expr.flag = packFlag(CONST, UINT);
        expr.data = abi.encode(value);
    }

    function makeConst(int256 value) internal pure returns (Expression memory expr) {
        expr.flag = packFlag(CONST, INT);
        expr.data = abi.encode(value);
    }

    function makeConst(address value) internal pure returns (Expression memory expr) {
        expr.flag = packFlag(CONST, ADDRESS);
        expr.data = abi.encode(value);
    }

    function makeConst(bool value) internal pure returns (Expression memory expr) {
        expr.flag = packFlag(CONST, BOOL);
        expr.data = abi.encode(value);
    }

    function makeConst(bytes memory value) internal pure returns (Expression memory expr) {
        expr.flag = packFlag(CONST, BYTES);
        expr.data = abi.encode(value);
    }

    function makeName(bytes32 name, uint8 typ) internal pure returns (Expression memory expr) {
        expr.flag = packFlag(VAR_NAME, typ);
        expr.data = abi.encode(name);
    }
}

struct Rule {
    Expression[] exprs;
}

library RuleLib {
    function getAddress(Rule memory rule) internal view returns (address) {
        return WriteOnce.getPointer(abi.encode(rule));
    }

    function store(Rule memory rule) internal returns (address) {
        return WriteOnce.store(abi.encode(rule));
    }

    function load(address id) internal view returns (Rule memory rule) {
        rule = abi.decode(WriteOnce.load(id), (Rule));
    }
}
