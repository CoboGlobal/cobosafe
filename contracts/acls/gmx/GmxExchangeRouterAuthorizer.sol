// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../auth/FarmingBaseACL.sol";

interface DepositUtils {
    struct CreateDepositParams {
        address receiver;
        address callbackContract;
        address uiFeeReceiver;
        address market;
        address initialLongToken;
        address initialShortToken;
        address[] longTokenSwapPath;
        address[] shortTokenSwapPath;
        uint256 minMarketTokens;
        bool shouldUnwrapNativeToken;
        uint256 executionFee;
        uint256 callbackGasLimit;
    }
}

interface WithdrawalUtils {
    struct CreateWithdrawalParams {
        address receiver;
        address callbackContract;
        address uiFeeReceiver;
        address market;
        address[] longTokenSwapPath;
        address[] shortTokenSwapPath;
        uint256 minLongTokenAmount;
        uint256 minShortTokenAmount;
        bool shouldUnwrapNativeToken;
        uint256 executionFee;
        uint256 callbackGasLimit;
    }
}

contract GmxExchangeRouterAuthorizer is FarmingBaseACL {
    bytes32 public constant NAME = "GmxExchangeRouterAuthorizer";
    uint256 public constant VERSION = 1;

    address public constant ExchangeRouter = 0x7C68C7866A64FA2160F78EEaE12217FFbf871fa8;
    address public constant DepositVault = 0xF89e77e8Dc11691C9e8757e84aaFbCD8A67d7A55;
    address public constant WithdrawalVault = 0x0628D46b5D145f183AdB6Ef1f2c97eD1C4701C55;

    constructor(address _owner, address _caller) FarmingBaseACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](1);

        _contracts[0] = ExchangeRouter;
    }

    // ACL methods

    function createDeposit(DepositUtils.CreateDepositParams calldata params) external {
        revert("Invalid request");
    }

    function createWithdrawal(WithdrawalUtils.CreateWithdrawalParams calldata params) external {
        revert("Invalid request");
    }

    function multicall(bytes[] calldata data) external view onlyContract(ExchangeRouter) {
        // use 'require' to check the access
        // use '_checkRecipient' to check the recipient
        require(data.length > 1, "Invalid multicall length");
        address receiverToCheck = address(0);
        for (uint256 i = 0; i < data.length; i++) {
            bytes4 method = bytes4(data[i][0:4]);
            bytes calldata argsData = data[i][4:];

            if (i < data.length - 1) {
                if (method == this.sendWnt.selector || method == this.sendNativeToken.selector) {
                    (address receiver, ) = abi.decode(argsData, (address, uint256));
                    require(receiver == DepositVault || receiver == WithdrawalVault, "Invalid native recipient");
                    require(receiverToCheck == address(0) || receiverToCheck == receiver, "Invalid receiver");
                    receiverToCheck = receiver;
                } else if (method == this.sendTokens.selector) {
                    (, address receiver, ) = abi.decode(argsData, (address, address, uint256));
                    require(receiver == DepositVault || receiver == WithdrawalVault, "Invalid token recipient");
                    require(receiverToCheck == address(0) || receiverToCheck == receiver, "Invalid receiver");
                    receiverToCheck = receiver;
                } else {
                    revert("Invalid method");
                }
            } else {
                if (method == this.createDeposit.selector) {
                    require(receiverToCheck == DepositVault, "Invalid deposit receiver");
                    DepositUtils.CreateDepositParams memory params = abi.decode(
                        argsData,
                        (DepositUtils.CreateDepositParams)
                    );
                    _checkRecipient(params.receiver);
                    _checkAllowPoolAddress(params.market);
                    require(params.callbackContract == address(0), "Invalid callback contract");
                    require(params.callbackGasLimit == 0, "Invalid callback gas limit");
                } else if (method == this.createWithdrawal.selector) {
                    require(receiverToCheck == WithdrawalVault, "Invalid withdrawal receiver");
                    WithdrawalUtils.CreateWithdrawalParams memory params = abi.decode(
                        argsData,
                        (WithdrawalUtils.CreateWithdrawalParams)
                    );
                    _checkRecipient(params.receiver);
                    _checkAllowPoolAddress(params.market);
                    require(params.callbackContract == address(0), "Invalid callback contract");
                    require(params.callbackGasLimit == 0, "Invalid callback gas limit");
                } else {
                    revert("Invalid method");
                }
            }
        }
        receiverToCheck = address(0);
    }

    function sendNativeToken(address receiver, uint256 amount) external {
        revert("Invalid request");
    }

    function sendTokens(address token, address receiver, uint256 amount) external {
        revert("Invalid request");
    }

    function sendWnt(address receiver, uint256 amount) external {
        revert("Invalid request");
    }
}
