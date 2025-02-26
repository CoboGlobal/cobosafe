// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../BaseTest.sol";
import {TransferRecorder} from "../../contracts/auth/rate/TransferRecorder.sol";
import {TransferRateLimitAuthorizer} from "../../contracts/auth/rate/TransferRateLimitAuthorizer.sol";
import {BaseRateLimitAuthorizer} from "../../contracts/auth/rate/BaseRateLimitAuthorizer.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// forge test --match-contract  TransferRateLimitAuthorizerForkTest -vv

contract TransferRateLimitAuthorizerForkTest is BaseTest {
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

    function test_TransferRateLimitAuthorizerFork0() public {
        TransferRecorder transferRecorder = new TransferRecorder(owner, cobosafe.authorizer());
        TransferRateLimitAuthorizer transferAuthorizer = new TransferRateLimitAuthorizer(owner, cobosafe.authorizer());
        addAuthorizer(address(transferRecorder));
        addAuthorizer(address(transferAuthorizer));

        transferAuthorizer.setRecorder(address(transferRecorder));
        assertEq(address(transferRecorder), transferAuthorizer.recorderAuthorizer());

        BaseRateLimitAuthorizer.TokenAccountAllowance[]
            memory _tokenReceiverAllowances = new BaseRateLimitAuthorizer.TokenAccountAllowance[](1);
        _tokenReceiverAllowances[0] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: PANCAKEROUTER,
            limit: 100,
            period: 20
        });

        transferAuthorizer.setTokenAccountAllowance(_tokenReceiverAllowances);
        address[] memory _allTokens = transferAuthorizer.getTokens(0, 10);
        assertEq(BUSD, _allTokens[0]);

        address[] memory _busdRecivers = transferAuthorizer.getTokenAccounts(BUSD, 0, 10);
        assertEq(PANCAKEROUTER, _busdRecivers[0]);

        uint256 _busdPancakeRouterAllowance1 = transferAuthorizer.getTokenAccountAllowance(BUSD, PANCAKEROUTER, 20);
        assertEq(100, _busdPancakeRouterAllowance1);

        // no policy match
        vm.expectRevert(bytes("E48"));
        coboSafeCall(FACTORY, 4000, new bytes(0));
        vm.expectRevert(bytes("E48"));
        coboSafeCall(WBNB, 0, abi.encodeCall(ERC20.transfer, (MASTERCHEF, 1000)));
        vm.expectRevert(bytes("E48"));
        coboSafeCall(address(0), 0, abi.encodeCall(ERC20.transfer, (MASTERCHEF, 100)));
    }

    function test_TransferRateLimitAuthorizerFork1() public {
        TransferRecorder transferRecorder = new TransferRecorder(owner, cobosafe.authorizer());
        TransferRateLimitAuthorizer transferAuthorizer = new TransferRateLimitAuthorizer(owner, cobosafe.authorizer());
        addAuthorizer(address(transferRecorder));
        addAuthorizer(address(transferAuthorizer));

        transferAuthorizer.setRecorder(address(transferRecorder));
        assertEq(address(transferRecorder), transferAuthorizer.recorderAuthorizer());

        BaseRateLimitAuthorizer.TokenAccountAllowance[]
            memory _tokenReceiverAllowances = new BaseRateLimitAuthorizer.TokenAccountAllowance[](3);
        _tokenReceiverAllowances[0] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: PANCAKEROUTER,
            limit: 100,
            period: 20
        });
        _tokenReceiverAllowances[1] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: MASTERCHEF,
            limit: 100,
            period: 20
        });
        _tokenReceiverAllowances[2] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: ANY,
            limit: 200,
            period: 20
        });

        transferAuthorizer.setTokenAccountAllowance(_tokenReceiverAllowances);
        uint256 _busdPancakeRouterAllowance1 = transferAuthorizer.getTokenAccountAllowance(BUSD, PANCAKEROUTER, 20);
        assertEq(100, _busdPancakeRouterAllowance1);
        // case 1
        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (PANCAKEROUTER, 100)));
        // case 2
        vm.expectRevert(bytes("E48"));
        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (PANCAKEROUTER, 20)));
        // case 3
        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (MASTERCHEF, 100)));

        skip(20);
        // runPostExecProcess() tx in period
        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (PANCAKEROUTER, 0)));
        vm.expectRevert(bytes("E48"));
        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (PANCAKEROUTER, 20)));
        skip(1);
        // runPostExecProcess() tx out period
        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (PANCAKEROUTER, 100)));
    }

    function test_TransferRateLimitAuthorizerFork2() public {
        TransferRecorder transferRecorder = new TransferRecorder(owner, cobosafe.authorizer());
        TransferRateLimitAuthorizer transferAuthorizer = new TransferRateLimitAuthorizer(owner, cobosafe.authorizer());
        addAuthorizer(address(transferRecorder));
        addAuthorizer(address(transferAuthorizer));

        transferAuthorizer.setRecorder(address(transferRecorder));
        assertEq(address(transferRecorder), transferAuthorizer.recorderAuthorizer());

        BaseRateLimitAuthorizer.TokenAccountAllowance[]
            memory _tokenReceiverAllowances = new BaseRateLimitAuthorizer.TokenAccountAllowance[](4);
        _tokenReceiverAllowances[0] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: PANCAKEROUTER,
            limit: 100,
            period: 20
        });
        _tokenReceiverAllowances[1] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: MASTERCHEF,
            limit: 100,
            period: 20
        });
        _tokenReceiverAllowances[2] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: ANY,
            limit: 200,
            period: 20
        });
        _tokenReceiverAllowances[3] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: WBNB,
            account: ANY,
            limit: 200,
            period: 0
        });

        transferAuthorizer.setTokenAccountAllowance(_tokenReceiverAllowances);
        uint256 _busdPancakeRouterAllowance1 = transferAuthorizer.getTokenAccountAllowance(BUSD, PANCAKEROUTER, 20);
        assertEq(100, _busdPancakeRouterAllowance1);
        // case 4
        coboSafeCall(WBNB, 0, abi.encodeCall(ERC20.transfer, (MASTERCHEF, 120)));
        // case 5
        skip(21);
        vm.expectRevert(bytes("E48"));
        coboSafeCall(WBNB, 0, abi.encodeCall(ERC20.transfer, (MASTERCHEF, 220)));
    }

    function test_TransferRateLimitAuthorizerFork3() public {
        TransferRecorder transferRecorder = new TransferRecorder(owner, cobosafe.authorizer());
        TransferRateLimitAuthorizer transferAuthorizer = new TransferRateLimitAuthorizer(owner, cobosafe.authorizer());
        addAuthorizer(address(transferRecorder));
        addAuthorizer(address(transferAuthorizer));

        transferAuthorizer.setRecorder(address(transferRecorder));
        assertEq(address(transferRecorder), transferAuthorizer.recorderAuthorizer());

        BaseRateLimitAuthorizer.TokenAccountAllowance[]
            memory _tokenReceiverAllowances = new BaseRateLimitAuthorizer.TokenAccountAllowance[](5);
        _tokenReceiverAllowances[0] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: PANCAKEROUTER,
            limit: 100,
            period: 20
        });
        _tokenReceiverAllowances[1] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: MASTERCHEF,
            limit: 500,
            period: 20
        });
        _tokenReceiverAllowances[2] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: ANY,
            limit: 200,
            period: 20
        });
        _tokenReceiverAllowances[3] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: ANY,
            limit: 200,
            period: 0
        });
        _tokenReceiverAllowances[4] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: MASTERCHEF,
            limit: type(uint208).max,
            period: 0
        });

        transferAuthorizer.setTokenAccountAllowance(_tokenReceiverAllowances);
        uint256 _busdPancakeRouterAllowance1 = transferAuthorizer.getTokenAccountAllowance(BUSD, PANCAKEROUTER, 20);
        assertEq(100, _busdPancakeRouterAllowance1);
        // case 6
        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (PANCAKEROUTER, 100)));
        // case 7
        vm.expectRevert(bytes("E48"));
        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (MASTERCHEF, 190)));
        skip(21);
        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (MASTERCHEF, 190)));
        // case 8
        skip(21);
        vm.expectRevert(bytes("E48"));
        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (MASTERCHEF, 220)));
    }

    function test_TransferRateLimitAuthorizerFork4() public {
        TransferRecorder transferRecorder = new TransferRecorder(owner, cobosafe.authorizer());
        TransferRateLimitAuthorizer transferAuthorizer = new TransferRateLimitAuthorizer(owner, cobosafe.authorizer());
        addAuthorizer(address(transferRecorder));
        addAuthorizer(address(transferAuthorizer));

        transferAuthorizer.setRecorder(address(transferRecorder));
        assertEq(address(transferRecorder), transferAuthorizer.recorderAuthorizer());

        BaseRateLimitAuthorizer.TokenAccountAllowance[]
            memory _tokenReceiverAllowances = new BaseRateLimitAuthorizer.TokenAccountAllowance[](4);
        _tokenReceiverAllowances[0] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: PANCAKEROUTER, // PANCAKEROUTER -> A
            limit: 100,
            period: 20
        });
        _tokenReceiverAllowances[1] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: ANY,
            limit: 200,
            period: 20
        });
        _tokenReceiverAllowances[2] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: WBNB,
            account: MASTERCHEF, // MASTERCHEF -> B
            limit: 100,
            period: 0
        });
        _tokenReceiverAllowances[3] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: WBNB,
            account: ANY,
            limit: 200,
            period: 0
        });
        transferAuthorizer.setTokenAccountAllowance(_tokenReceiverAllowances);

        // case 9
        vm.expectRevert(bytes("E48"));
        coboSafeCall(FACTORY, 100, new bytes(0)); // FACTORY -> C

        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (PANCAKEROUTER, 100)));
        skip(21);
        vm.expectRevert(bytes("E48"));
        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (PANCAKEROUTER, 200)));

        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (FACTORY, 200)));
        skip(21);
        vm.expectRevert(bytes("E48"));
        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (FACTORY, 300)));

        skip(21);
        vm.expectRevert(bytes("E48"));
        coboSafeCall(PANCAKEROUTER, 400, new bytes(0));

        coboSafeCall(WBNB, 0, abi.encodeCall(ERC20.transfer, (MASTERCHEF, 100)));
        skip(21);
        vm.expectRevert(bytes("E48"));
        coboSafeCall(WBNB, 0, abi.encodeCall(ERC20.transfer, (MASTERCHEF, 200)));

        coboSafeCall(WBNB, 0, abi.encodeCall(ERC20.transfer, (FACTORY, 200)));
        skip(21);
        vm.expectRevert(bytes("E48"));
        coboSafeCall(WBNB, 0, abi.encodeCall(ERC20.transfer, (FACTORY, 300)));

        skip(21);
        vm.expectRevert(bytes("E48"));
        coboSafeCall(MASTERCHEF, 400, new bytes(0));
    }

    function test_TransferRateLimitAuthorizerFork5() public {
        TransferRecorder transferRecorder = new TransferRecorder(owner, cobosafe.authorizer());
        TransferRateLimitAuthorizer transferAuthorizer0 = new TransferRateLimitAuthorizer(owner, cobosafe.authorizer());
        TransferRateLimitAuthorizer transferAuthorizer1 = new TransferRateLimitAuthorizer(owner, cobosafe.authorizer());
        addAuthorizer(address(transferRecorder));
        addAuthorizer(address(transferAuthorizer0));
        addAuthorizer(address(transferAuthorizer1));

        transferAuthorizer0.setRecorder(address(transferRecorder));
        assertEq(address(transferRecorder), transferAuthorizer0.recorderAuthorizer());
        transferAuthorizer1.setRecorder(address(transferRecorder));
        assertEq(address(transferRecorder), transferAuthorizer1.recorderAuthorizer());

        BaseRateLimitAuthorizer.TokenAccountAllowance[]
            memory _tokenReceiverAllowances0 = new BaseRateLimitAuthorizer.TokenAccountAllowance[](1);
        _tokenReceiverAllowances0[0] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: PANCAKEROUTER, // PANCAKEROUTER -> A
            limit: 100,
            period: 20
        });

        transferAuthorizer0.setTokenAccountAllowance(_tokenReceiverAllowances0);
        uint256 _busdPancakeRouterAllowance01 = transferAuthorizer0.getTokenAccountAllowance(BUSD, PANCAKEROUTER, 20);
        assertEq(100, _busdPancakeRouterAllowance01);

        BaseRateLimitAuthorizer.TokenAccountAllowance[]
            memory _tokenReceiverAllowances1 = new BaseRateLimitAuthorizer.TokenAccountAllowance[](1);
        _tokenReceiverAllowances1[0] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: PANCAKEROUTER, // PANCAKEROUTER -> A
            limit: type(uint208).max,
            period: 0
        });

        transferAuthorizer1.setTokenAccountAllowance(_tokenReceiverAllowances1);
        uint256 _busdPancakeRouterAllowance10 = transferAuthorizer1.getTokenAccountAllowance(BUSD, PANCAKEROUTER, 0);
        assertEq(type(uint208).max, _busdPancakeRouterAllowance10);

        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (PANCAKEROUTER, 200)));
    }

    function test_TransferRateLimitAuthorizerFork6() public {
        TransferRecorder transferRecorder = new TransferRecorder(owner, cobosafe.authorizer());
        TransferRateLimitAuthorizer transferAuthorizer = new TransferRateLimitAuthorizer(owner, cobosafe.authorizer());
        addAuthorizer(address(transferRecorder));
        addAuthorizer(address(transferAuthorizer));

        transferAuthorizer.setRecorder(address(transferRecorder));
        assertEq(address(transferRecorder), transferAuthorizer.recorderAuthorizer());

        BaseRateLimitAuthorizer.TokenAccountAllowance[]
            memory _tokenReceiverAllowances = new BaseRateLimitAuthorizer.TokenAccountAllowance[](3);
        _tokenReceiverAllowances[0] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: PANCAKEROUTER,
            limit: 200,
            period: 20
        });
        _tokenReceiverAllowances[1] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: PANCAKEROUTER,
            limit: 600,
            period: 60
        });
        _tokenReceiverAllowances[2] = BaseRateLimitAuthorizer.TokenAccountAllowance({
            token: BUSD,
            account: PANCAKEROUTER,
            limit: 1000,
            period: 0
        });

        transferAuthorizer.setTokenAccountAllowance(_tokenReceiverAllowances);

        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (PANCAKEROUTER, 200)));
        skip(21);
        vm.expectRevert(bytes("E48"));
        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (PANCAKEROUTER, 600)));
        coboSafeCall(BUSD, 0, abi.encodeCall(ERC20.transfer, (PANCAKEROUTER, 200)));

        uint256 _busdPancakeRouterAllowance0 = transferAuthorizer.getTokenAccountAllowance(BUSD, PANCAKEROUTER, 0);
        assertEq(1000, _busdPancakeRouterAllowance0);
        uint256 _busdPancakeRouterAllowance1 = transferAuthorizer.getTokenAccountAllowance(BUSD, PANCAKEROUTER, 20);
        assertEq(200, _busdPancakeRouterAllowance1);

        BaseRateLimitAuthorizer.TokenAccountUnset[]
            memory _unSetTokenReceiverAllowances = new BaseRateLimitAuthorizer.TokenAccountUnset[](2);
        _unSetTokenReceiverAllowances[0] = BaseRateLimitAuthorizer.TokenAccountUnset({
            token: BUSD,
            account: PANCAKEROUTER,
            period: 0
        });
        _unSetTokenReceiverAllowances[1] = BaseRateLimitAuthorizer.TokenAccountUnset({
            token: BUSD,
            account: PANCAKEROUTER,
            period: 20
        });
        transferAuthorizer.unsetTokenAccountAllowance(_unSetTokenReceiverAllowances);
        uint256 _busdPancakeRouterAllowance0Unset = transferAuthorizer.getTokenAccountAllowance(BUSD, PANCAKEROUTER, 0);
        assertEq(0, _busdPancakeRouterAllowance0Unset);
        uint256 _busdPancakeRouterAllowance1Unset = transferAuthorizer.getTokenAccountAllowance(
            BUSD,
            PANCAKEROUTER,
            20
        );
        assertEq(0, _busdPancakeRouterAllowance1Unset);
    }
}
