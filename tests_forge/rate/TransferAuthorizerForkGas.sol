// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../BaseTest.sol";
import {TransferRecorder} from "../../contracts/auth/rate/TransferRecorder.sol";
import {TransferRateLimitAuthorizer} from "../../contracts/auth/rate/TransferRateLimitAuthorizer.sol";
import {BaseRateLimitAuthorizer} from "../../contracts/auth/rate/BaseRateLimitAuthorizer.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// forge test --match-contract  TransferAuthorizerForkGas -vv

contract TransferAuthorizerForkGas is BaseTest {
    address constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant PANCAKEROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MASTERCHEF = 0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652;
    address constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address constant ANY = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
    address constant FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    TransferRecorder transferRecorder;
    TransferRateLimitAuthorizer transferAuthorizer;

    uint constant TR = 1000; // token -> receiver tx records
    uint constant TA = 1000; // token -> ANY tx records

    function setUp() public override {
        initFork("mainnet");
        super.setUp();

        transferRecorder = new TransferRecorder(owner, cobosafe.authorizer());
        transferAuthorizer = new TransferRateLimitAuthorizer(owner, cobosafe.authorizer());
        addAuthorizer(address(transferRecorder));
        addAuthorizer(address(transferAuthorizer));

        transferAuthorizer.setRecorder(address(transferRecorder));
        assertEq(address(transferRecorder), transferAuthorizer.recorderAuthorizer());

        BaseRateLimitAuthorizer.TokenAccountAllowance[]
            memory _tokenReceiverAllowances = new BaseRateLimitAuthorizer.TokenAccountAllowance[](2);
        _tokenReceiverAllowances[0] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: PANCAKEROUTER, // PANCAKEROUTER -> A
            limit: type(uint256).max,
            period: 10 ** 5
        });
        _tokenReceiverAllowances[1] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: ANY,
            limit: type(uint256).max,
            period: 10 ** 5
        });

        transferAuthorizer.setTokenAccountAllowance(_tokenReceiverAllowances);

        vm.startPrank(cobosafe.authorizer());

        if (TR > 0) {
            for (uint i = 0; i < TR; i++) {
                runPostExecProcess(
                    address(transferRecorder),
                    address(BUSD),
                    0,
                    abi.encodeCall(ERC20.transfer, (MASTERCHEF, 10))
                );
            }
        }

        if (TA > 0) {
            for (uint i = 0; i < TA; i++) {
                runPostExecProcess(
                    address(transferRecorder),
                    address(BUSD),
                    0,
                    abi.encodeCall(ERC20.transfer, (PANCAKEROUTER, 10))
                );
            }
        }

        vm.stopPrank();

        assertEq(TR, transferRecorder.getTokenAccountRecordsLength(BUSD, MASTERCHEF));
        assertEq(TA, transferRecorder.getTokenAccountRecordsLength(BUSD, PANCAKEROUTER));
    }

    function test_TokenTransferGas() public {
        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (PANCAKEROUTER, 10)));
    }
}
