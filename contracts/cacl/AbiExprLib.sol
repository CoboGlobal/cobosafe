// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

/*

    https://ethereum.stackexchange.com/questions/1106/is-there-a-limit-for-transaction-size
    calldata max length < 800k < uint32 max

    uint8 flag           uint32
    ------
    move,                offset                    -> ptr += offset
    jump,                offset                    -> ptr += ptr[offset]
    index-move,          index(int), element_size  -> ptr += 32 + (index > 0? index: index + ptr[0]) * element_size
    index-jump           index(int), element_size  -> ptr += 32 + ptr[32 + (index > 0? index: index + ptr[0]) * element_size]
    extract-static,      size                      -> return [ptr: ptr+size]
    extract-end,                                   -> return \x20, [ptr: end] as dynamic size, just extract all.
    extract-elements,    element_size              -> return [ptr + 32: ptr 32 + ptr[0] * element_size]

*/
function getUint256(bytes calldata data, uint256 offset) pure returns (uint256 value) {
    value = uint256(bytes32(data[offset:offset + 32]));
}

function getUint32(bytes memory path, uint256 offset) pure returns (uint256 value) {
    value = uint256(uint8(bytes1(path[offset])));
    value = (value << 8) | uint256(uint8(bytes1(path[offset + 1])));
    value = (value << 8) | uint256(uint8(bytes1(path[offset + 2])));
    value = (value << 8) | uint256(uint8(bytes1(path[offset + 3])));
}

function getInt32(bytes memory path, uint256 offset) pure returns (int256 value) {
    value = int256(getUint32(path, offset));
    if (value > 0x80000000) {
        value = value - 0x100000000;
    }
}

function evalAbiExpr(bytes calldata data, bytes memory path) pure returns (bytes memory extractedBytes) {
    uint256 ptr = 0;
    uint256 i = 0;
    uint8 op = 0;
    uint256 pathLen = path.length;
    uint256 offset = 0;
    int256 index = 0;
    uint256 size = 0;
    uint256 elementSize = 0;

    while (i < pathLen) {
        op = uint8(path[i]);
        ++i;
        if (op == 1) {
            // move(offset): ptr += offset
            offset = getUint32(path, i);
            ptr += offset;
            i += 4;
        } else if (op == 2) {
            // jump(offset): ptr += ptr[offset]
            offset = getUint32(path, i);
            i += 4;
            ptr += getUint256(data, ptr + offset);
        } else if (op == 3) {
            // index_move(index, element_size): ptr += 32 + (index > 0? index: index + ptr[0]) * element_size
            index = getInt32(path, i);
            i += 4;
            elementSize = getUint32(path, i);
            i += 4;
            size = getUint256(data, ptr);
            if (index < 0) {
                index += int256(size);
            }
            require(index >= 0, "Invalid move index");
            offset = 32 + uint256(index) * elementSize;
            ptr += offset;
        } else if (op == 4) {
            // index_jump(index, element_size): ptr += 32 + ptr[32 + (index > 0? index: index + ptr[0]) * element_size]
            index = getInt32(path, i);
            i += 4;
            elementSize = getUint32(path, i);
            i += 4;
            size = getUint256(data, ptr);
            if (index < 0) {
                index += int256(size);
            }
            offset = 32 + uint256(index) * elementSize;
            ptr += 32 + getUint256(data, ptr + offset);
        } else if (op == 5) {
            // extract-static(size): return [ptr: ptr+size]
            size = getUint32(path, i);
            // we will return here, no need to update i
            return data[ptr:ptr + size];
        } else if (op == 6) {
            // extract-end(): return \x20, [ptr: end] as dynamic size, just extract all.
            return abi.encodePacked(abi.encode(0x20), data[ptr:]);
        } else if (op == 7) {
            // extract-elements(element_size): return [ptr + 32: ptr 32 + ptr[0] * element_size]
            elementSize = getUint32(path, i);
            size = getUint256(data, ptr);
            // we will return here, no need to update i
            return data[ptr + 32:ptr + 32 + size * elementSize];
        } else {
            revert("Invalid abi expr op");
        }
    }

    revert("Empty abi expr");
}
