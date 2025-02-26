// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../BaseTest.sol";
import {CompoundV2Market} from "../../contracts/permissions/compoundv2/CompoundV2Market.sol";
import {CompoundV2Mint, ICToken} from "../../contracts/permissions/compoundv2/CompoundV2Mint.sol";
import {CompoundV2Redeem} from "../../contracts/permissions/compoundv2/CompoundV2Redeem.sol";
import {CompoundV2Borrow} from "../../contracts/permissions/compoundv2/CompoundV2Borrow.sol";
import {CompoundV2Repay} from "../../contracts/permissions/compoundv2/CompoundV2Repay.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CompoundV2ForkTest is BaseTest {
    address constant cETH = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;
    address constant cDAI = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    address constant cUSDT = 0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    address[] tokens;

    function setUp() public override {
        initFork("mainnet");

        super.setUp();

        tokens.push(cETH);
        tokens.push(cDAI);
        tokens.push(cUSDT);
    }

    function test_CompoundV2Market() public {
        CompoundV2Market perm = new CompoundV2Market(owner, owner);
        perm.addAllowedTokens(tokens);

        addAuthorizer(address(perm));

        address to = perm.UNITROLLER();
        coboSafeCall(to, 0, abi.encodeCall(perm.enterMarkets, (tokens)));

        coboSafeCall(to, 0, abi.encodeCall(perm.exitMarket, (cETH)));

        vm.expectRevert(bytes("E48"));
        coboSafeCall(to, 0, abi.encodeCall(perm.exitMarket, (USDT)));
    }

    function test_CompoundV2MintRedeem() public {
        CompoundV2Mint perm = new CompoundV2Mint(owner, owner);
        perm.addAllowedTokens(tokens);
        assertTrue(perm.checkTokenSpender(USDT, cUSDT));

        addAuthorizer(address(perm));

        assertEq(ERC20(cETH).balanceOf(address(safe)), 0);
        coboSafeCall(cETH, 1 ether, abi.encodeWithSignature("mint()"));
        assertGe(ERC20(cETH).balanceOf(address(safe)), 0);

        coboSafeCall(DAI, 0, abi.encodeCall(ERC20.approve, (cDAI, type(uint256).max)));

        assertEq(ERC20(DAI).allowance(address(safe), cDAI), type(uint256).max);

        uint256 amount = 10000 ether;

        vm.prank(DAI);
        ERC20(DAI).transfer(address(safe), amount);
        assertEq(ERC20(DAI).balanceOf(address(safe)), amount);

        coboSafeCall(cDAI, 0, abi.encodeWithSignature("mint(uint256)", amount));
        assertGe(ERC20(cDAI).balanceOf(address(safe)), 0);

        perm.removeAllowedTokens(tokens);

        vm.expectRevert(bytes("E48"));
        coboSafeCall(cETH, 1 ether, abi.encodeWithSignature("mint()"));

        vm.expectRevert(bytes("E48"));
        coboSafeCall(DAI, 0, abi.encodeCall(ERC20.approve, (cDAI, type(uint256).max)));

        CompoundV2Redeem _perm = new CompoundV2Redeem(owner, owner);
        _perm.addAllowedTokens(tokens);
        addAuthorizer(address(_perm));

        coboSafeCall(cDAI, 0, abi.encodeCall(_perm.redeem, (ERC20(cDAI).balanceOf(address(safe)))));

        assertEq(ERC20(cDAI).balanceOf(address(safe)), 0);
    }

    function test_CompoundV2BorrowRepay() public {
        CompoundV2Mint permMint = new CompoundV2Mint(owner, owner);
        permMint.addAllowedTokens(tokens);
        addAuthorizer(address(permMint));

        CompoundV2Market permMarket = new CompoundV2Market(owner, owner);
        permMarket.addAllowedTokens(tokens);
        addAuthorizer(address(permMarket));

        CompoundV2Borrow permBorrow = new CompoundV2Borrow(owner, owner);
        permBorrow.addAllowedTokens(tokens);
        addAuthorizer(address(permBorrow));

        CompoundV2Repay permRepay = new CompoundV2Repay(owner, owner);
        permRepay.addAllowedTokens(tokens);
        addAuthorizer(address(permRepay));

        coboSafeCall(cETH, 10 ether, abi.encodeWithSignature("mint()"));
        coboSafeCall(permMarket.UNITROLLER(), 0, abi.encodeCall(permMarket.enterMarkets, (tokens)));

        uint256 amount = 1 ether;
        coboSafeCall(cETH, 0, abi.encodeCall(permBorrow.borrow, (amount)));

        coboSafeCall(cDAI, 0, abi.encodeCall(permBorrow.borrow, (amount)));

        assertEq(ERC20(DAI).balanceOf(address(safe)), amount);

        coboSafeCall(DAI, 0, abi.encodeCall(ERC20.approve, (cDAI, type(uint256).max)));
        coboSafeCall(cDAI, 0, abi.encodeWithSignature("repayBorrow(uint256)", amount));

        coboSafeCall(cETH, amount, abi.encodeWithSignature("repayBorrow()"));
    }
}
