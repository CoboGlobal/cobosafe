// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../BaseTest.sol";
import {ApprovalRecorder} from "../../contracts/auth/rate/ApprovalRecorder.sol";
import {ApprovalRateLimitAuthorizer} from "../../contracts/auth/rate/ApprovalRateLimitAuthorizer.sol";
import {BaseRateLimitAuthorizer} from "../../contracts/auth/rate/BaseRateLimitAuthorizer.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// forge test --match-contract  ApprovalRecorderForkTest -vv

contract ApprovalRecorderForkTest is BaseTest {
    address constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant PANCAKEROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MASTERCHEF = 0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652;
    address constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address constant ANY = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
    address constant FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    function setUp() public override {
        initFork("mainnet");
        super.setUp();
    }

    function test_ApprovalRecorderFork() public {
        ApprovalRecorder approvalRecorder = new ApprovalRecorder(owner, cobosafe.authorizer());
        ApprovalRateLimitAuthorizer approvalAuthorizer = new ApprovalRateLimitAuthorizer(owner, cobosafe.authorizer());
        addAuthorizer(address(approvalRecorder));
        addAuthorizer(address(approvalAuthorizer));

        BaseRateLimitAuthorizer.TokenAccountAllowance[]
            memory _tokenAccountAllowances = new BaseRateLimitAuthorizer.TokenAccountAllowance[](3);
        _tokenAccountAllowances[0] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: ANY,
            limit: type(uint208).max,
            period: 0
        });
        _tokenAccountAllowances[1] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: WBNB,
            account: ANY,
            limit: type(uint208).max,
            period: 0
        });
        _tokenAccountAllowances[2] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: USDT,
            account: ANY,
            limit: type(uint208).max,
            period: 0
        });
        approvalAuthorizer.setTokenAccountAllowance(_tokenAccountAllowances);

        console.log("ApprovalRecorder.owner():", approvalRecorder.owner());
        console.log("ApprovalRecorder.caller():", approvalRecorder.caller());

        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.approve, (MASTERCHEF, 1000)));
        coboSafeCall(WBNB, 0, abi.encodeCall(ERC20.approve, (PANCAKEROUTER, 1000)));
        coboSafeCall(WBNB, 0, abi.encodeCall(ERC20.approve, (MASTERCHEF, 1000)));
        coboSafeCall(USDT, 0, abi.encodeCall(ERC20.approve, (PANCAKEROUTER, 3000)));
        coboSafeCall(USDT, 0, abi.encodeCall(ERC20.approve, (FACTORY, 2000)));

        // transfer
        // 1000 BUSD to MASTERCHEF,
        // 1000 WBNB to PANCAKEROUTER,
        // 1000 WBNB to MASTERCHEF,
        // 3000 USDT to PANCAKEROUTER,
        // 2000 USDT to FACTORY
        // at timestamp 1

        address[] memory _ApprovalRecorderTokens = approvalRecorder.getTokens(0, 10);
        console.log("_ApprovalRecorderTokens[0]:", _ApprovalRecorderTokens[0]);
        assertEq(BUSD, _ApprovalRecorderTokens[0]);
        assertEq(WBNB, _ApprovalRecorderTokens[1]);
        assertEq(USDT, _ApprovalRecorderTokens[2]);

        address[] memory _ApprovalRecorderTokenAccounts = approvalRecorder.getTokenAccounts(WBNB, 0, 10);
        console.log("_ApprovalRecorderTokenAccounts[0]:", _ApprovalRecorderTokenAccounts[0]);
        assertEq(PANCAKEROUTER, _ApprovalRecorderTokenAccounts[0]);
        assertEq(MASTERCHEF, _ApprovalRecorderTokenAccounts[1]);

        address[] memory _ApprovalRecorderUSDTAccounts = approvalRecorder.getTokenAccounts(USDT, 0, 10);
        assertEq(PANCAKEROUTER, _ApprovalRecorderUSDTAccounts[0]);

        skip(10);
        // transfer
        // 2000 WBNB to MASTERCHEF,
        // at timestamp 11
        coboSafeCall(WBNB, 0, abi.encodeCall(ERC20.approve, (MASTERCHEF, 2000)));
        // transfer WBNB to MASTERCHEF at timestamp 11
        ApprovalRecorder.AccountRecord[] memory _AccountRecords = approvalRecorder.getTokenAccountRecords(
            WBNB,
            MASTERCHEF,
            0,
            10
        );
        assertEq(1000, _AccountRecords[0].amount);
        assertEq(uint64(block.timestamp) - 10, _AccountRecords[0].timestamp);
        assertEq(2000, _AccountRecords[1].amount);
        assertEq(uint64(block.timestamp), _AccountRecords[1].timestamp);

        // transfer
        // 4000 USDT to FACTORY
        // at timestamp 11
        coboSafeCall(USDT, 0, abi.encodeCall(ERC20.approve, (FACTORY, 4000)));
        ApprovalRecorder.AccountRecord[] memory _transferEthRecords = approvalRecorder.getTokenAccountRecords(
            USDT,
            FACTORY,
            0,
            10
        );
        assertEq(4000, _transferEthRecords[1].amount);
        assertEq(uint64(block.timestamp), _transferEthRecords[1].timestamp);

        skip(10);
        //  getPeriodAmount at timestamp 21

        // token -> Account -> period

        // USDT -> FACTORY           // approvalRecorder.getTokenAccountRecords(USDT,FACTORY);
        // [AccountRecord({ amount: 2000, timestamp: 1 }), AccountRecord({ amount: 4000, timestamp: 11 })]
        uint256 _ethFactoryAmountPeriod5 = approvalRecorder.getPeriodAmount(USDT, FACTORY, 5);
        assertEq(_ethFactoryAmountPeriod5, 0);
        uint256 _ethFactoryAmountPeriod10 = approvalRecorder.getPeriodAmount(USDT, FACTORY, 10);
        assertEq(_ethFactoryAmountPeriod10, 4000);
        uint256 _ethFactoryAmountPeriod15 = approvalRecorder.getPeriodAmount(USDT, FACTORY, 15);
        assertEq(_ethFactoryAmountPeriod15, 4000);
        uint256 _ethFactoryAmountPeriod19 = approvalRecorder.getPeriodAmount(USDT, FACTORY, 19);
        assertEq(_ethFactoryAmountPeriod19, 4000);
        uint256 _ethFactoryAmountPeriod20 = approvalRecorder.getPeriodAmount(USDT, FACTORY, 20);
        assertEq(_ethFactoryAmountPeriod20, 6000);
        uint256 _ethFactoryAmountPeriod21 = approvalRecorder.getPeriodAmount(USDT, FACTORY, 21);
        assertEq(_ethFactoryAmountPeriod21, 6000);

        // token -> ANY -> period

        // USDT -> PANCAKEROUTER     // approvalRecorder.getTokenAccountRecords(USDT,PANCAKEROUTER);
        // [AccountRecord({ amount: 3000, timestamp: 1 })]
        // USDT -> FACTORY           // approvalRecorder.getTokenAccountRecords(USDT,FACTORY);
        // [AccountRecord({ amount: 2000, timestamp: 1 }), AccountRecord({ amount: 4000, timestamp: 11 })]
        uint256 _ethAnyAmountPeriod5 = approvalRecorder.getPeriodAmount(USDT, ANY, 5);
        assertEq(_ethAnyAmountPeriod5, 0);
        uint256 _ethAnyAmountPeriod10 = approvalRecorder.getPeriodAmount(USDT, ANY, 10);
        assertEq(_ethAnyAmountPeriod10, 4000);
        uint256 _ethAnyAmountPeriod15 = approvalRecorder.getPeriodAmount(USDT, ANY, 15);
        assertEq(_ethAnyAmountPeriod15, 4000);
        uint256 _ethAnyAmountPeriod19 = approvalRecorder.getPeriodAmount(USDT, ANY, 19);
        assertEq(_ethAnyAmountPeriod19, 4000);
        uint256 _ethAnyAmountPeriod20 = approvalRecorder.getPeriodAmount(USDT, ANY, 20);
        assertEq(_ethAnyAmountPeriod20, 9000);
        uint256 _ethAnyAmountPeriod21 = approvalRecorder.getPeriodAmount(USDT, ANY, 21);
        assertEq(_ethAnyAmountPeriod21, 9000);

        vm.startPrank(cobosafe.authorizer());
        // ApprovalRecorder do not allow ANY method
        assertFalse(
            checkPerm(
                address(approvalRecorder),
                address(BUSD),
                0,
                abi.encodeWithSignature("transfer(address,uint256)", MASTERCHEF, 1000)
            )
        );
        assertFalse(
            checkPerm(
                address(approvalRecorder),
                address(BUSD),
                0,
                abi.encodeWithSignature("approve(address,uint256)", MASTERCHEF, 1000)
            )
        );
        vm.stopPrank();

        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.approve, (address(0), 9000)));
        ApprovalRecorder.AccountRecord[] memory _transferZeroRecords = approvalRecorder.getTokenAccountRecords(
            BUSD,
            address(0),
            0,
            10
        );
        assertEq(9000, _transferZeroRecords[0].amount);

        // ApprovalRecorder do not allow token address(0)
        vm.expectRevert(bytes("E48"));
        coboSafeCall(address(0), 0, abi.encodeCall(ERC20.approve, (address(0), 9000)));

        assertEq(0, approvalRecorder.getTokenAccountRecordsLength(address(0), address(0)));

        // ApprovalRecorder do not allow token address(0)
        vm.expectRevert(bytes("E48"));
        coboSafeCall(address(0), 0, abi.encodeCall(ERC20.approve, (MASTERCHEF, 9000)));

        assertEq(0, approvalRecorder.getTokenAccountRecordsLength(address(0), MASTERCHEF));

        ApprovalRecorder.AccountRecord[] memory _AccountRecordsIndex = approvalRecorder.getTokenAccountRecords(
            WBNB,
            MASTERCHEF,
            0,
            7
        );
        assertEq(1000, _AccountRecordsIndex[0].amount);
        assertEq(2000, _AccountRecordsIndex[1].amount);

        assertEq(2, approvalRecorder.getTokenAccountRecordsLength(WBNB, MASTERCHEF));
    }
}
