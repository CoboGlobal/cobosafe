// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./console.sol";

contract ConsoleTest {
    function logBool() external {
        console.log(true);
    }

    function logInt() external {
        console.log(int256(-1234));
    }

    function logUint() external {
        console.log(uint256(1234));
    }

    function logBytes32() external {
        console.log(bytes32("AAAAAA"));
    }

    function logBytes() external {
        console.log(bytes(hex"12345678"));
    }

    function logAddress() external {
        console.log(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }

    function logString() external {
        console.log(string("this is a string"));
    }

    function errorBool() external {
        console.error(true);
    }

    function errorInt() external {
        console.error(int256(-1234));
    }

    function errorUint() external {
        console.error(uint256(1234));
    }

    function errorBytes32() external {
        console.error(bytes32("12345678"));
    }

    function errorBytes() external {
        console.error(bytes(hex"12345678"));
    }

    function errorAddress() external {
        console.error(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }

    function errorString() external {
        console.error(string("this is a string"));
    }
}
