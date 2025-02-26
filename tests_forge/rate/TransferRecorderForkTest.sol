// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../BaseTest.sol";
import {TransferRecorder} from "../../contracts/auth/rate/TransferRecorder.sol";
import {TransferRateLimitAuthorizer} from "../../contracts/auth/rate/TransferRateLimitAuthorizer.sol";
import {BaseRateLimitAuthorizer} from "../../contracts/auth/rate/BaseRateLimitAuthorizer.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// forge test --match-contract  TransferRecorderForkTest -vv

contract TransferRecorderForkTest is BaseTest {
    address constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant PANCAKEROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MASTERCHEF = 0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652;
    address constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address constant ANY = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
    address constant FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    function setUp() public override {
        initFork("mainnet");
        super.setUp();
    }

    function test_TransferRecorderFork() public {
        TransferRecorder transferRecorder = new TransferRecorder(owner, cobosafe.authorizer());
        TransferRateLimitAuthorizer transferAuthorizer = new TransferRateLimitAuthorizer(owner, cobosafe.authorizer());
        addAuthorizer(address(transferRecorder));
        addAuthorizer(address(transferAuthorizer));

        BaseRateLimitAuthorizer.TokenAccountAllowance[]
            memory _tokenAccountAllowances = new BaseRateLimitAuthorizer.TokenAccountAllowance[](5);
        _tokenAccountAllowances[0] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: ANY,
            limit: type(uint256).max,
            period: 0
        });
        _tokenAccountAllowances[1] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: WBNB,
            account: ANY,
            limit: type(uint256).max,
            period: 0
        });
        _tokenAccountAllowances[2] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: ETH,
            account: ANY,
            limit: type(uint256).max,
            period: 0
        });
        _tokenAccountAllowances[3] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: ANY,
            account: address(0),
            limit: type(uint256).max,
            period: 0
        });
        _tokenAccountAllowances[4] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: ANY,
            account: MASTERCHEF,
            limit: type(uint256).max,
            period: 0
        });
        transferAuthorizer.setTokenAccountAllowance(_tokenAccountAllowances);

        console.log("TransferRecorder.owner():", transferRecorder.owner());
        console.log("TransferRecorder.caller():", transferRecorder.caller());

        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (MASTERCHEF, 1000)));
        coboSafeCall(WBNB, 0, abi.encodeCall(ERC20.transfer, (PANCAKEROUTER, 1000)));
        coboSafeCall(WBNB, 0, abi.encodeCall(ERC20.transfer, (MASTERCHEF, 1000)));
        coboSafeCall(PANCAKEROUTER, 3000, new bytes(0));
        coboSafeCall(FACTORY, 2000, new bytes(0));

        // transfer
        // 1000 BUSD to MASTERCHEF,
        // 1000 WBNB to PANCAKEROUTER,
        // 1000 WBNB to MASTERCHEF,
        // 3000 ETH to PANCAKEROUTER,
        // 2000 ETH to FACTORY
        // at timestamp 1

        address[] memory _TransferRecorderTokens = transferRecorder.getTokens(0, 10);
        console.log("_TransferRecorderTokens[0]:", _TransferRecorderTokens[0]);
        assertEq(BUSD, _TransferRecorderTokens[0]);
        assertEq(WBNB, _TransferRecorderTokens[1]);
        assertEq(ETH, _TransferRecorderTokens[2]);

        address[] memory _TransferRecorderTokenAccounts = transferRecorder.getTokenAccounts(WBNB, 0, 10);
        console.log("_TransferRecorderTokenAccounts[0]:", _TransferRecorderTokenAccounts[0]);
        assertEq(PANCAKEROUTER, _TransferRecorderTokenAccounts[0]);
        assertEq(MASTERCHEF, _TransferRecorderTokenAccounts[1]);

        address[] memory _TransferRecorderETHAccounts = transferRecorder.getTokenAccounts(ETH, 0, 10);
        assertEq(PANCAKEROUTER, _TransferRecorderETHAccounts[0]);

        skip(10);
        // transfer
        // 2000 WBNB to MASTERCHEF,
        // at timestamp 11
        coboSafeCall(WBNB, 0, abi.encodeCall(ERC20.transfer, (MASTERCHEF, 2000)));
        // transfer WBNB to MASTERCHEF at timestamp 11
        TransferRecorder.AccountRecord[] memory _AccountRecords = transferRecorder.getTokenAccountRecords(
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
        // 4000 ETH to FACTORY
        // at timestamp 11
        coboSafeCall(FACTORY, 4000, new bytes(0));
        TransferRecorder.AccountRecord[] memory _transferEthRecords = transferRecorder.getTokenAccountRecords(
            ETH,
            FACTORY,
            0,
            10
        );
        assertEq(4000, _transferEthRecords[1].amount);
        assertEq(uint64(block.timestamp), _transferEthRecords[1].timestamp);

        skip(10);
        //  getPeriodAmount at timestamp 21

        // token -> Account -> period

        // ETH -> FACTORY           // transferRecorder.getTokenAccountRecords(ETH,FACTORY);
        // [AccountRecord({ amount: 2000, timestamp: 1 }), AccountRecord({ amount: 4000, timestamp: 11 })]
        uint256 _ethFactoryAmountPeriod5 = transferRecorder.getPeriodAmount(ETH, FACTORY, 5);
        assertEq(_ethFactoryAmountPeriod5, 0);
        uint256 _ethFactoryAmountPeriod10 = transferRecorder.getPeriodAmount(ETH, FACTORY, 10);
        assertEq(_ethFactoryAmountPeriod10, 4000);
        uint256 _ethFactoryAmountPeriod15 = transferRecorder.getPeriodAmount(ETH, FACTORY, 15);
        assertEq(_ethFactoryAmountPeriod15, 4000);
        uint256 _ethFactoryAmountPeriod19 = transferRecorder.getPeriodAmount(ETH, FACTORY, 19);
        assertEq(_ethFactoryAmountPeriod19, 4000);
        uint256 _ethFactoryAmountPeriod20 = transferRecorder.getPeriodAmount(ETH, FACTORY, 20);
        assertEq(_ethFactoryAmountPeriod20, 6000);
        uint256 _ethFactoryAmountPeriod21 = transferRecorder.getPeriodAmount(ETH, FACTORY, 21);
        assertEq(_ethFactoryAmountPeriod21, 6000);

        // token -> ANY -> period

        // ETH -> PANCAKEROUTER     // transferRecorder.getTokenAccountRecords(ETH,PANCAKEROUTER);
        // [AccountRecord({ amount: 3000, timestamp: 1 })]
        // ETH -> FACTORY           // transferRecorder.getTokenAccountRecords(ETH,FACTORY);
        // [AccountRecord({ amount: 2000, timestamp: 1 }), AccountRecord({ amount: 4000, timestamp: 11 })]
        uint256 _ethAnyAmountPeriod5 = transferRecorder.getPeriodAmount(ETH, ANY, 5);
        assertEq(_ethAnyAmountPeriod5, 0);
        uint256 _ethAnyAmountPeriod10 = transferRecorder.getPeriodAmount(ETH, ANY, 10);
        assertEq(_ethAnyAmountPeriod10, 4000);
        uint256 _ethAnyAmountPeriod15 = transferRecorder.getPeriodAmount(ETH, ANY, 15);
        assertEq(_ethAnyAmountPeriod15, 4000);
        uint256 _ethAnyAmountPeriod19 = transferRecorder.getPeriodAmount(ETH, ANY, 19);
        assertEq(_ethAnyAmountPeriod19, 4000);
        uint256 _ethAnyAmountPeriod20 = transferRecorder.getPeriodAmount(ETH, ANY, 20);
        assertEq(_ethAnyAmountPeriod20, 9000);
        uint256 _ethAnyAmountPeriod21 = transferRecorder.getPeriodAmount(ETH, ANY, 21);
        assertEq(_ethAnyAmountPeriod21, 9000);

        vm.startPrank(cobosafe.authorizer());
        // TransferRecorder do not allow ANY method
        assertFalse(
            checkPerm(
                address(transferRecorder),
                address(BUSD),
                0,
                abi.encodeWithSignature("transfer(address,uint256)", MASTERCHEF, 1000)
            )
        );
        assertFalse(
            checkPerm(
                address(transferRecorder),
                address(BUSD),
                0,
                abi.encodeWithSignature("approve(address,uint256)", MASTERCHEF, 1000)
            )
        );
        vm.stopPrank();

        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (address(0), 9000)));
        TransferRecorder.AccountRecord[] memory _transferZeroRecords = transferRecorder.getTokenAccountRecords(
            BUSD,
            address(0),
            0,
            10
        );
        assertEq(9000, _transferZeroRecords[0].amount);

        // TransferRecorder do not allow token address(0)
        vm.expectRevert(bytes("E48"));
        coboSafeCall(address(0), 0, abi.encodeCall(ERC20.transfer, (address(0), 9000)));

        assertEq(0, transferRecorder.getTokenAccountRecordsLength(address(0), address(0)));

        // TransferRecorder do not allow token address(0)
        vm.expectRevert(bytes("E48"));
        coboSafeCall(address(0), 0, abi.encodeCall(ERC20.transfer, (MASTERCHEF, 9000)));

        assertEq(0, transferRecorder.getTokenAccountRecordsLength(address(0), MASTERCHEF));

        TransferRecorder.AccountRecord[] memory _AccountRecordsIndex = transferRecorder.getTokenAccountRecords(
            WBNB,
            MASTERCHEF,
            0,
            7
        );
        assertEq(1000, _AccountRecordsIndex[0].amount);
        assertEq(2000, _AccountRecordsIndex[1].amount);

        assertEq(2, transferRecorder.getTokenAccountRecordsLength(WBNB, MASTERCHEF));
    }

    function test_TransferRecorderCacheFork() public {
        TransferRecorder transferRecorder = new TransferRecorder(owner, cobosafe.authorizer());

        vm.startPrank(cobosafe.authorizer());
        runPostExecProcess(address(transferRecorder), address(WBNB), 0, abi.encodeCall(ERC20.transfer, (FACTORY, 10)));
        skip(10);
        runPostExecProcess(address(transferRecorder), address(WBNB), 0, abi.encodeCall(ERC20.transfer, (FACTORY, 20)));
        skip(10);
        runPostExecProcess(
            address(transferRecorder),
            address(WBNB),
            0,
            abi.encodeCall(ERC20.transfer, (PANCAKEROUTER, 10))
        );
        TransferRecorder.AccountRecord[] memory _wbnbFactoryRecords = transferRecorder.getTokenAccountRecords(
            WBNB,
            FACTORY,
            0,
            10
        );
        assertEq(_wbnbFactoryRecords.length, 2);
        assertEq(_wbnbFactoryRecords[1].amount, 20);

        TransferRecorder.PeriodTotalCache[] memory _wbnbFactoryCaches = transferRecorder.getTokenAccountCaches(
            WBNB,
            FACTORY,
            0,
            10
        );
        assertEq(_wbnbFactoryCaches.length, 1);
        assertEq(_wbnbFactoryCaches[0].totalAmount, 30);

        uint256[] memory _wbnbFactoryIndexs = transferRecorder.getTokenAccountCacheIndexs(WBNB, FACTORY, 0);
        assertEq(_wbnbFactoryIndexs.length, 2);
        assertEq(_wbnbFactoryIndexs[0], 0);
        assertEq(_wbnbFactoryIndexs[1], 1);

        uint256 _wbnbFactoryPeriodAmount = transferRecorder.getPeriodAmount(WBNB, FACTORY, 50);
        assertEq(_wbnbFactoryPeriodAmount, 30);

        TransferRecorder.AccountRecord[] memory _wbnbPancakeRecords = transferRecorder.getTokenAccountRecords(
            WBNB,
            PANCAKEROUTER,
            0,
            10
        );
        assertEq(_wbnbPancakeRecords.length, 1);
        assertEq(_wbnbPancakeRecords[0].amount, 10);

        TransferRecorder.PeriodTotalCache[] memory _wbnbPancakeCaches = transferRecorder.getTokenAccountCaches(
            WBNB,
            PANCAKEROUTER,
            0,
            10
        );
        assertEq(_wbnbPancakeCaches.length, 1);
        assertEq(_wbnbPancakeCaches[0].totalAmount, 10);

        uint256[] memory _wbnbPancakeIndexs = transferRecorder.getTokenAccountCacheIndexs(WBNB, PANCAKEROUTER, 0);
        assertEq(_wbnbPancakeIndexs.length, 1);
        assertEq(_wbnbPancakeIndexs[0], 0);

        uint256 _wbnbPancakePeriodAmount = transferRecorder.getPeriodAmount(WBNB, PANCAKEROUTER, 50);
        assertEq(_wbnbPancakePeriodAmount, 10);

        for (uint i = 0; i < 108; i++) {
            runPostExecProcess(
                address(transferRecorder),
                address(BUSD),
                0,
                abi.encodeCall(ERC20.transfer, (PANCAKEROUTER, 10))
            );
        }

        TransferRecorder.AccountRecord[] memory _busdPancakeRecords = transferRecorder.getTokenAccountRecords(
            BUSD,
            PANCAKEROUTER,
            0,
            200
        );
        assertEq(_busdPancakeRecords.length, 108);
        assertEq(_busdPancakeRecords[107].amount, 10);

        TransferRecorder.PeriodTotalCache[] memory _busdPancakeCaches = transferRecorder.getTokenAccountCaches(
            BUSD,
            PANCAKEROUTER,
            0,
            100
        );
        assertEq(_busdPancakeCaches.length, 6);
        assertEq(_busdPancakeCaches[4].totalAmount, 200);
        assertEq(_busdPancakeCaches[5].totalAmount, 80);

        uint256[] memory _busdPancakeIndexs4 = transferRecorder.getTokenAccountCacheIndexs(BUSD, PANCAKEROUTER, 4);
        assertEq(_busdPancakeIndexs4.length, 20);
        assertEq(_busdPancakeIndexs4[19], 99);

        uint256[] memory _busdPancakeIndexs5 = transferRecorder.getTokenAccountCacheIndexs(BUSD, PANCAKEROUTER, 5);
        assertEq(_busdPancakeIndexs5.length, 8);
        assertEq(_busdPancakeIndexs5[7], 107);

        uint256 _busdPancakePeriodAmount = transferRecorder.getPeriodAmount(BUSD, PANCAKEROUTER, 5000);
        assertEq(_busdPancakePeriodAmount, 1080);

        vm.stopPrank();
    }
}
