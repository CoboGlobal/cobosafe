// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../base/BaseSimpleACL.sol";

contract EqbPendleaUSDCDepositor is BaseSimpleACL {
    bytes32 public constant NAME = "EqbPendleaUSDCDepositor";
    uint256 public constant VERSION = 1;

    address public constant PendleRouterV3 = 0x00000000005BBB0EF59571E58418F9a4357b68A0;
    address public constant aArbUSDCn = 0x724dc807b04555b71ed48a6896b6F41593b8C637;
    address public constant USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address public constant PendleMarket = 0x8621c587059357d6C669f72dA3Bfe1398fc0D0B5; // LP aUSDC
    address public constant PendleBooster = 0x4D32C8Ff2fACC771eC7Efc70d6A8468bC30C26bF;
    uint256 public constant PID = 17;

    constructor(address _owner, address _caller) BaseSimpleACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](2);
        _contracts[0] = PendleRouterV3;
        _contracts[1] = PendleBooster;
    }

    struct TokenInput {
        // Token/Sy data
        address tokenIn;
        uint256 netTokenIn;
        address tokenMintSy;
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

    // deposit
    function addLiquiditySingleTokenKeepYt(
        address receiver,
        address market,
        uint256 minLpOut,
        uint256 minYtOut,
        TokenInput calldata input
    ) external view nonPayable onlyContract(PendleRouterV3) {
        _checkRecipient(receiver);
        require(market == PendleMarket, "market not allowed");

        _tokenInputCheck(input);
    }

    function deposit(uint256 _pid, uint256 _amount, bool _stake) external view nonPayable onlyContract(PendleBooster) {
        require(_pid == PID, "_pid not allowed");
    }

    // internal
    function _tokenInputCheck(TokenInput calldata input) internal view {
        SwapType swapType = input.swapData.swapType;

        require(swapType == SwapType.NONE, "swapType not allowed");
        require(
            (input.tokenIn == aArbUSDCn && input.tokenMintSy == aArbUSDCn) ||
                (input.tokenIn == USDC && input.tokenMintSy == USDC),
            "tokenIn or tokenMintSy not allowed"
        );
    }
}
