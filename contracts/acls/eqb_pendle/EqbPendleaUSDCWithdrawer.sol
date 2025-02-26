// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../base/BaseSimpleACL.sol";

contract EqbPendleaUSDCWithdrawer is BaseSimpleACL {
    bytes32 public constant NAME = "EqbPendleaUSDCWithdrawer";
    uint256 public constant VERSION = 1;

    address public constant PendleRouterV3 = 0x00000000005BBB0EF59571E58418F9a4357b68A0;
    address public constant aArbUSDCn = 0x724dc807b04555b71ed48a6896b6F41593b8C637;
    address public constant USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address public constant PendleMarket = 0x8621c587059357d6C669f72dA3Bfe1398fc0D0B5; // LP aUSDC
    address public constant EqbZap = 0xc7517f481Cc0a645e63f870830A4B2e580421e32;
    address public constant YTaUSDC = 0xA1c32EF8d3c4c30cB596bAb8647e11daF0FA5C94;
    address public constant SYaUSDC = 0x50288c30c37FA1Ec6167a31E575EA8632645dE20;
    uint256 public constant PID = 17;

    constructor(address _owner, address _caller) BaseSimpleACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](2);
        _contracts[0] = PendleRouterV3;
        _contracts[1] = EqbZap;
    }

    struct TokenOutput {
        // Token/Sy data
        address tokenOut;
        uint256 minTokenOut;
        address tokenRedeemSy;
        // aggregator data
        address pendleSwap;
        SwapData swapData;
    }

    struct SwapData {
        SwapType swapType;
        address extRouter;
        bytes extCalldata;
        bool needScale;
    }

    enum SwapType {
        NONE,
        KYBERSWAP,
        ONE_INCH,
        // ETH_WETH not used in Aggregator
        ETH_WETH
    }

    // acl

    // withdraw
    function withdraw(uint256 _pid, uint256 _amount) external view nonPayable onlyContract(EqbZap) {
        require(_pid == PID, "_pid not allowed");
    }

    function removeLiquidityDualTokenAndPt(
        address receiver,
        address market,
        uint256 netLpToRemove,
        TokenOutput calldata output,
        uint256 minPtOut
    ) external view nonPayable onlyContract(PendleRouterV3) {
        _checkRecipient(receiver);
        require(market == PendleMarket, "market not allowed");

        _tokenOutputCheck(output);
    }

    function redeemPyToSy(
        address receiver,
        address YT,
        uint256 netPyIn,
        uint256 minSyOut
    ) external view nonPayable onlyContract(PendleRouterV3) {
        _checkRecipient(receiver);
        require(YT == YTaUSDC, "YT not allowed");
    }

    function redeemPyToToken(
        address receiver,
        address YT,
        uint256 netPyIn,
        TokenOutput calldata output
    ) external view nonPayable onlyContract(PendleRouterV3) {
        _checkRecipient(receiver);
        require(YT == YTaUSDC, "YT not allowed");

        _tokenOutputCheck(output);
    }

    function redeemSyToToken(
        address receiver,
        address SY,
        uint256 netSyIn,
        TokenOutput calldata output
    ) external view nonPayable onlyContract(PendleRouterV3) {
        _checkRecipient(receiver);
        require(SY == SYaUSDC, "SY not allowed");

        _tokenOutputCheck(output);
    }

    // internal
    function _tokenOutputCheck(TokenOutput calldata output) internal view {
        SwapType swapType = output.swapData.swapType;

        require(swapType == SwapType.NONE, "swapType not allowed");
        require(
            (output.tokenOut == aArbUSDCn && output.tokenRedeemSy == aArbUSDCn) ||
                (output.tokenOut == USDC && output.tokenRedeemSy == USDC),
            "tokenOut or tokenRedeemSy not allowed"
        );
    }
}
