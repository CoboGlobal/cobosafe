// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../BaseTest.sol";
import {CompoundV2Market} from "../../contracts/permissions/compoundv2/CompoundV2Market.sol";
import {CompoundV2Mint, ICToken} from "../../contracts/permissions/compoundv2/CompoundV2Mint.sol";
import {CompoundV2Redeem} from "../../contracts/permissions/compoundv2/CompoundV2Redeem.sol";
import {CompoundV2Borrow} from "../../contracts/permissions/compoundv2/CompoundV2Borrow.sol";
import {CompoundV2Repay} from "../../contracts/permissions/compoundv2/CompoundV2Repay.sol";

contract MockCToken is ICToken {
    bool public constant isCToken = true;
    address public underlying;

    constructor(address _underlying) {
        underlying = _underlying;
    }
}

contract CompoundV2Test is BaseTest {
    address token1 = address(1);
    address token2 = address(2);
    address token3 = address(3);

    MockCToken c1;
    MockCToken c2;
    address[] tokens;

    function setUp() public override {
        c1 = new MockCToken(token1);
        c2 = new MockCToken(token2);

        tokens.push(address(c1));
        tokens.push(address(c2));
    }

    function test_CompoundV2Market() public {
        CompoundV2Market perm = new CompoundV2Market(owner, owner);

        perm.addAllowedTokens(tokens);

        checkAllowed(address(perm), perm.UNITROLLER(), 0, abi.encodeCall(perm.enterMarkets, (tokens)));

        checkAllowed(address(perm), perm.UNITROLLER(), 0, abi.encodeCall(perm.exitMarket, (address(c1))));

        vm.expectRevert("Token not allowed");
        perm.exitMarket(token1);
    }

    function test_CompoundV2Mint() public {
        CompoundV2Mint perm = new CompoundV2Mint(owner, owner);
        perm.addAllowedTokens(tokens);

        assertTrue(perm.checkTokenSpender(c1.underlying(), address(c1)));

        assertTrue(checkPerm(address(perm), address(c1), 0, abi.encodeWithSignature("mint(uint256)", 1)));

        assertFalse(checkPerm(address(perm), address(c1), 0, abi.encodeWithSignature("mint()")));

        perm.removeAllowedTokens(tokens);
        assertFalse(perm.checkTokenSpender(c1.underlying(), address(c1)));
    }

    function test_CompoundV2Redeem() public {
        CompoundV2Redeem perm = new CompoundV2Redeem(owner, owner);
        address[] memory _tokens = new address[](1);
        _tokens[0] = address(c1);

        perm.addAllowedTokens(_tokens);
        address[] memory _contracts = perm.contracts();

        assertEq(_tokens.length, _contracts.length);
        assertEq(_tokens[0], _contracts[0]);

        assertTrue(checkPerm(address(perm), address(c1), 0, abi.encodeCall(perm.redeem, (1))));

        // Invalid cToken
        assertFalse(checkPerm(address(perm), address(c2), 0, abi.encodeCall(perm.redeem, (1))));
    }

    function test_CompoundV2Borrow() public {
        CompoundV2Borrow perm = new CompoundV2Borrow(owner, owner);
        perm.addAllowedTokens(tokens);
        assertTrue(checkPerm(address(perm), address(c1), 0, abi.encodeCall(perm.borrow, (1))));

        assertTrue(checkPerm(address(perm), address(c2), 0, abi.encodeCall(perm.borrow, (1))));
    }

    function test_CompoundV2Repay() public {
        CompoundV2Repay perm = new CompoundV2Repay(owner, owner);
        perm.addAllowedTokens(tokens);

        assertTrue(checkPerm(address(perm), address(c1), 0, abi.encodeWithSignature("repayBorrow(uint256)", (1))));

        assertTrue(
            checkPerm(
                address(perm),
                address(c2),
                0,
                abi.encodeWithSignature("repayBorrowBehalf(address,uint256)", owner, uint256(1))
            )
        );

        assertFalse(
            checkPerm(
                address(perm),
                address(c2),
                0,
                abi.encodeWithSignature("repayBorrowBehalf(address,uint256)", delegate, uint256(1))
            )
        );
    }
}
