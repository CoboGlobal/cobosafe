// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Strings.sol";

library console {
    bytes16 private constant SYMBOLS = "0123456789abcdef";

    event Log(bool);
    event Log(address);
    event Log(int256);
    event Log(uint256);
    event Log(bytes32);
    event Log(string);
    event Log(bytes);

    function log(bool v) internal {
        emit Log(v);
    }

    function log(address v) internal {
        emit Log(v);
    }

    function log(int256 v) internal {
        emit Log(v);
    }

    function log(uint256 v) internal {
        emit Log(v);
    }

    function log(bytes32 v) internal {
        emit Log(v);
    }

    function log(bytes memory v) internal {
        emit Log(v);
    }

    function log(string memory v) internal {
        emit Log(v);
    }

    function toString(bool v) internal view returns (string memory) {
        if (v) return "true";
        else return "false";
    }

    function toString(address v) internal view returns (string memory) {
        return Strings.toHexString(v);
    }

    function toString(uint256 v) internal view returns (string memory) {
        return Strings.toString(v);
    }

    function toString(int256 v) internal view returns (string memory) {
        uint256 value;
        if (v < 0) value = uint256(-v);
        else value = uint256(v);
        return string(abi.encodePacked(v < 0 ? "-" : "", toString(value)));
    }

    function toString(bytes32 v) internal view returns (string memory) {
        return Strings.toHexString(uint256(v));
    }

    function toString(bytes memory v) internal view returns (string memory) {
        bytes memory buffer = new bytes(2 * v.length);
        for (uint256 i = 0; i < v.length; i++) {
            uint8 value = uint8(v[i]);
            buffer[2 * i + 1] = SYMBOLS[value & 0xf];
            value >>= 4;
            buffer[2 * i] = SYMBOLS[value & 0xf];
        }
        return string(buffer);
    }

    function error(bool v) internal view {
        revert(toString(v));
    }

    function error(int256 v) internal view {
        revert(toString(v));
    }

    function error(uint256 v) internal view {
        revert(toString(v));
    }

    function error(bytes32 v) internal view {
        revert(toString(v));
    }

    function error(address v) internal view {
        revert(toString(v));
    }

    function error(bytes memory v) internal view {
        revert(toString(v));
    }

    function error(string memory v) internal view {
        revert(v);
    }
}
