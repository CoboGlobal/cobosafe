// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CaclTestSuite {
    address immutable owner;

    constructor() {
        owner = msg.sender;
    }

    function foo(address a) external {}

    function foo(bool a) external {}

    function foo(uint256 a) external {}

    function bar1(string calldata a) external payable {}

    function bar2(bytes[1] calldata a) external payable {}

    function bar3(int[] calldata a) external payable {}

    function testBasic1(
        address a1,
        bool a2,
        uint256 a3,
        int256 a4,
        bytes calldata a5,
        string calldata a6,
        bytes32 a7
    ) external {}

    function testBasic2(uint8 a1, uint128 a2, int16 a3, int32 a4, bytes1 a5, bytes4 a6, bytes18 a7) external {}

    function testDynArray(
        address[] calldata a1,
        bool[] calldata a2,
        uint256[] calldata a3,
        int256[] calldata a4,
        bytes[] calldata a5,
        string[] calldata a6,
        bytes32[] calldata a7
    ) external {}

    function testFixedArray(uint8[10] calldata a1, uint128[1] calldata a2, int16[3] calldata a3) external {}

    function testComplexArray(
        bool[10][][1] calldata a1,
        address[][] calldata a2,
        uint256[3][2] calldata a3,
        string[][1][] calldata a4
    ) external {}

    struct Object1 {
        address a1;
        bool a2;
        uint256 a3;
        int256 a4;
        bytes a5;
        string a6;
        bytes32 a7;
    }

    struct Object2 {
        Object1 o1;
        Object1[] o2;
    }

    struct Object3 {
        Object2[] x1;
        address[] x2;
        bool[][] x3;
        uint256[1][2] x4;
        bytes[][] x5;
        string[] x6;
        Object1[1] x7;
    }

    function testTuple1(Object1 calldata a1) external {}

    function testTuple2(Object2 calldata a2) external {}

    function testTuple3(Object3 calldata a3) external {}

    function testTuple4(Object3[] calldata a1, Object3[1] calldata a2) external {}

    receive() external payable {}

    function rescue(address token) external {
        address to = owner;
        if (token == address(0)) {
            (bool success, ) = payable(to).call{value: address(this).balance}("");
            require(success, "ETH transfer failed");
        } else {
            ERC20(token).transfer(0xABaABc27DC432A3F2AE4066a1d3C87f7afC192fD, ERC20(token).balanceOf(address(this)));
        }
    }
}
