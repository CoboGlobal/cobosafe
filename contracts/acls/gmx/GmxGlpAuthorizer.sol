// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../auth/FarmingBaseACL.sol";

contract GmxGlpAuthorizer is FarmingBaseACL {
    bytes32 public constant NAME = "GmxGlpAuthorizer";
    uint256 public constant VERSION = 1;
    address public constant GLP_REWAED_ROUTER = 0xB95DB5B167D75e6d04227CfFFA61069348d271F5;
    address public constant NATIVE_ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(address _owner, address _caller) FarmingBaseACL(_owner, _caller) {}

    function mintAndStakeGlp(
        address _token,
        uint256 _amount,
        uint256 _minUsdg,
        uint256 _minGlp
    ) external view onlyContract(GLP_REWAED_ROUTER) {
        _checkAllowPoolAddress(_token);
    }

    function unstakeAndRedeemGlp(
        address _tokenOut,
        uint256 _glpAmount,
        uint256 _minOut,
        address _receiver
    ) external view onlyContract(GLP_REWAED_ROUTER) {
        _checkAllowPoolAddress(_tokenOut);
        _checkRecipient(_receiver);
    }

    function mintAndStakeGlpETH(uint256 _minUsdg, uint256 _minGlp) external view onlyContract(GLP_REWAED_ROUTER) {
        _checkAllowPoolAddress(NATIVE_ETH);
    }

    function unstakeAndRedeemGlpETH(
        uint256 _glpAmount,
        uint256 _minOut,
        address payable _receiver
    ) external view onlyContract(GLP_REWAED_ROUTER) {
        _checkAllowPoolAddress(NATIVE_ETH);
        _checkRecipient(_receiver);
    }

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = GLP_REWAED_ROUTER;
    }
}
