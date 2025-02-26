// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Strings.sol";

import "./CaclTypes.sol";

// Comparison handlers

function raiseOpError(uint8 _op, string memory _type) pure {
    revert(string(abi.encodePacked("Unsupported op ", Strings.toString(uint256(_op)), " for type ", _type)));
}

function raiseTypeError(uint8 _type, string memory _op) pure {
    revert(string(abi.encodePacked("Unsupported type ", Strings.toString(uint256(_type)), " for op ", _op)));
}

function handleCmp(uint8 op, bytes memory v1, bytes memory v2) pure returns (bool) {
    if (op == EQ) return keccak256(v1) == keccak256(v2);
    if (op == NE) return keccak256(v1) != keccak256(v2);
    raiseOpError(op, "bytes");
}

function handleCmp(uint8 op, bool v1, bool v2) pure returns (bool) {
    if (op == EQ) return v1 == v2;
    if (op == NE) return v1 != v2;
    raiseOpError(op, "bool");
}

function handleCmp(uint8 op, address v1, address v2) pure returns (bool) {
    if (op == EQ) return v1 == v2;
    if (op == NE) return v1 != v2;
    raiseOpError(op, "address");
}

function handleCmp(uint8 op, uint256 v1, uint256 v2) pure returns (bool) {
    if (op == EQ) return v1 == v2;
    if (op == NE) return v1 != v2;
    if (op == GT) return v1 > v2;
    if (op == GE) return v1 >= v2;
    if (op == LT) return v1 < v2;
    if (op == LE) return v1 <= v2;
    raiseOpError(op, "uint256");
}

function handleCmp(uint8 op, int256 v1, int256 v2) pure returns (bool) {
    if (op == EQ) return v1 == v2;
    if (op == NE) return v1 != v2;
    if (op == GT) return v1 > v2;
    if (op == GE) return v1 >= v2;
    if (op == LT) return v1 < v2;
    if (op == LE) return v1 <= v2;
    raiseOpError(op, "int256");
}

function handleCmpRawData(uint8 op, uint8 typ, bytes memory v1Data, bytes memory v2Data) pure returns (bool) {
    if (typ == ADDRESS) {
        address v1 = abi.decode(v1Data, (address));
        address v2 = abi.decode(v2Data, (address));
        return handleCmp(op, v1, v2);
    } else if (typ == UINT) {
        uint256 v1 = abi.decode(v1Data, (uint256));
        uint256 v2 = abi.decode(v2Data, (uint256));
        return handleCmp(op, v1, v2);
    } else if (typ == INT) {
        int256 v1 = abi.decode(v1Data, (int256));
        int256 v2 = abi.decode(v2Data, (int256));
        return handleCmp(op, v1, v2);
    } else if (typ == BOOL) {
        bool v1 = abi.decode(v1Data, (bool));
        bool v2 = abi.decode(v2Data, (bool));
        return handleCmp(op, v1, v2);
    } else if (typ == BYTES) {
        // No need to abi.decode
        return handleCmp(op, v1Data, v2Data);
    }
    raiseTypeError(typ, "cmp");
}

function handleBool(uint8 op, bool v1, bool v2) pure returns (bool) {
    if (op == AND) return v1 && v2;
    if (op == OR) return v1 || v2;
    raiseOpError(op, "bool");
}

function handleNot(bool v1) pure returns (bool) {
    return !v1;
}

// Element in array.

function handleIn(bytes memory v1, bytes[] memory v2) pure returns (bool) {
    for (uint i = 0; i < v2.length; i++) {
        if (keccak256(v1) == keccak256(v2[i])) return true;
    }
    return false;
}

function handleIn(uint256 v1, uint256[] memory v2) pure returns (bool) {
    for (uint i = 0; i < v2.length; i++) {
        if (v1 == v2[i]) return true;
    }
    return false;
}

function handleIn(int256 v1, int256[] memory v2) pure returns (bool) {
    for (uint i = 0; i < v2.length; i++) {
        if (v1 == v2[i]) return true;
    }
    return false;
}

function handleIn(address v1, address[] memory v2) pure returns (bool) {
    for (uint i = 0; i < v2.length; i++) {
        if (v1 == v2[i]) return true;
    }
    return false;
}

// Array in array.

function handleIn(bytes[] memory v1, bytes[] memory v2) pure returns (bool) {
    // Check if all elements of v1 are in v2.
    for (uint i = 0; i < v1.length; i++) {
        if (!handleIn(v1[i], v2)) return false;
    }
    return true;
}

function handleIn(uint256[] memory v1, uint256[] memory v2) pure returns (bool) {
    // Check if all elements of v1 are in v2.
    for (uint i = 0; i < v1.length; i++) {
        if (!handleIn(v1[i], v2)) return false;
    }
    return true;
}

function handleIn(int256[] memory v1, int256[] memory v2) pure returns (bool) {
    // Check if all elements of v1 are in v2.
    for (uint i = 0; i < v1.length; i++) {
        if (!handleIn(v1[i], v2)) return false;
    }
    return true;
}

function handleIn(address[] memory v1, address[] memory v2) pure returns (bool) {
    // Check if all elements of v1 are in v2.
    for (uint i = 0; i < v1.length; i++) {
        if (!handleIn(v1[i], v2)) return false;
    }
    return true;
}

function handleArrayRawData(uint8 op, uint8 typ, bytes memory v1Data, bytes memory v2Data) pure returns (bool result) {
    // Put the most commonly used ones at the front.
    if (typ == ADDRESS) {
        address v1 = abi.decode(v1Data, (address));
        address[] memory v2 = abi.decode(v2Data, (address[]));
        result = handleIn(v1, v2);
    } else if (typ == ADDRESS_ARRAY) {
        // Used often,
        address[] memory v1 = abi.decode(v1Data, (address[]));
        address[] memory v2 = abi.decode(v2Data, (address[]));
        result = handleIn(v1, v2);
    } else if (typ == UINT) {
        uint256 v1 = abi.decode(v1Data, (uint256));
        uint256[] memory v2 = abi.decode(v2Data, (uint256[]));
        result = handleIn(v1, v2);
    } else if (typ == INT) {
        int256 v1 = abi.decode(v1Data, (int256));
        int256[] memory v2 = abi.decode(v2Data, (int256[]));
        result = handleIn(v1, v2);
    } else if (typ == BYTES) {
        bytes memory v1 = v1Data;
        bytes[] memory v2 = abi.decode(v2Data, (bytes[]));
        result = handleIn(v1, v2);
    } else if (typ == UINT_ARRAY) {
        uint256[] memory v1 = abi.decode(v1Data, (uint256[]));
        uint256[] memory v2 = abi.decode(v2Data, (uint256[]));
        result = handleIn(v1, v2);
    } else if (typ == INT_ARRAY) {
        int256[] memory v1 = abi.decode(v1Data, (int256[]));
        int256[] memory v2 = abi.decode(v2Data, (int256[]));
        result = handleIn(v1, v2);
    } else if (typ == BYTES_ARRAY) {
        bytes[] memory v1 = abi.decode(v1Data, (bytes[]));
        bytes[] memory v2 = abi.decode(v2Data, (bytes[]));
        result = handleIn(v1, v2);
    } else {
        raiseTypeError(typ, "in/not in");
    }
    if (op == NOT_IN) {
        result = !result;
    } else {
        if (op != IN) raiseOpError(op, "array");
    }
}
