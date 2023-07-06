from brownie import ZERO_ADDRESS
from tests.libtest import AuthorizerWrapper

# usage:
# 1、export WEB3_INFURA_PROJECT_ID=
# 2、brownie test tests/test_zzz_fork/acl/test_eth_BalancerAurarETHWETHAuthorizer_acl.py --network mainnet-fork -s


NETWORK_NAME = "mainnet-fork"

VAULT_ADDRESS = "0xba12222222228d8ba445958a75a0704d566bf2c8"
BOOSTER_ADDRESS = "0xa57b8d98dae62b26ec3bcc4a365338157060b234"


Balancer_rETH_WETH_PoolId = (
    "0x1e19cf2d73a72ef1332c882f20534b6519be0276000200000000000000000112"
)
bb_a_USD_pool = "0xa13a9247ea42d743238089903570127dda72fe4400000000000000000000035d"
Aura_rETH_WETH_PoolId = 109

rETH = "0xae78736Cd615f374D3085123A210448E74Fc6393"
B_rETH_STABLE = "0x1E19CF2D73a72Ef1332C882F20534B6519Be0276"
WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"


def test_balancer_relayer(BalancerAurarETHWETHAuthorizer, owner, delegate):
    balancerAurarETHWETHAuthorizer = BalancerAurarETHWETHAuthorizer.deploy(
        owner.address, owner.address, {"from": owner}
    )

    wrapper = AuthorizerWrapper(balancerAurarETHWETHAuthorizer)

    balancerAurarETHWETHAuthorizer.setBooster(BOOSTER_ADDRESS)
    balancerAurarETHWETHAuthorizer.setVault(VAULT_ADDRESS)
    assert balancerAurarETHWETHAuthorizer.BOOSTER_ADDRESS.call() == BOOSTER_ADDRESS
    assert balancerAurarETHWETHAuthorizer.VAULT_ADDRESS.call() == VAULT_ADDRESS

    balancerAurarETHWETHAuthorizer.addBalancerPoolIds([Balancer_rETH_WETH_PoolId])
    assert (
        Balancer_rETH_WETH_PoolId
        in balancerAurarETHWETHAuthorizer.getBalancerPoolIdWhiteList.call()
    ) is True

    # Balancer joinPool
    assert wrapper.pre_check_func(
        VAULT_ADDRESS,
        "joinPool(bytes32,address,address,(address[],uint256[],bytes,bool))",
        [
            bytes.fromhex(Balancer_rETH_WETH_PoolId[2:]),
            owner.address,
            owner.address,
            (
                [rETH, WETH],
                [9667366899120113815, 0],
                bytes.fromhex(
                    "000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000008c4501d8aa1d45c40000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000862962f98f6c88970000000000000000000000000000000000000000000000000000000000000000"
                ),
                False,
            ),
        ],
    )

    assert (
        wrapper.pre_check_func(
            VAULT_ADDRESS,
            "joinPool(bytes32,address,address,(address[],uint256[],bytes,bool))",
            [
                bytes.fromhex(Balancer_rETH_WETH_PoolId[2:]),
                ZERO_ADDRESS,
                owner.address,
                (
                    [rETH, WETH],
                    [9667366899120113815, 0],
                    bytes.fromhex(
                        "000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000008c4501d8aa1d45c40000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000862962f98f6c88970000000000000000000000000000000000000000000000000000000000000000"
                    ),
                    False,
                ),
            ],
        )
        is False
    )

    assert (
        wrapper.pre_check_func(
            VAULT_ADDRESS,
            "joinPool(bytes32,address,address,(address[],uint256[],bytes,bool))",
            [
                bytes.fromhex(Balancer_rETH_WETH_PoolId[2:]),
                owner.address,
                ZERO_ADDRESS,
                (
                    [rETH, WETH],
                    [9667366899120113815, 0],
                    bytes.fromhex(
                        "000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000008c4501d8aa1d45c40000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000862962f98f6c88970000000000000000000000000000000000000000000000000000000000000000"
                    ),
                    False,
                ),
            ],
        )
        is False
    )

    assert (
        wrapper.pre_check_func(
            VAULT_ADDRESS,
            "joinPool(bytes32,address,address,(address[],uint256[],bytes,bool))",
            [
                bytes.fromhex(bb_a_USD_pool[2:]),
                owner.address,
                owner.address,
                (
                    [rETH, WETH],
                    [9667366899120113815, 0],
                    bytes.fromhex(
                        "000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000008c4501d8aa1d45c40000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000862962f98f6c88970000000000000000000000000000000000000000000000000000000000000000"
                    ),
                    False,
                ),
            ],
        )
        is False
    )

    # Balancer exitPool
    # success
    assert wrapper.pre_check_func(
        VAULT_ADDRESS,
        "exitPool(bytes32,address,address,(address[],uint256[],bytes,bool))",
        [
            bytes.fromhex(Balancer_rETH_WETH_PoolId[2:]),
            owner.address,
            owner.address,
            (
                [rETH, WETH],
                [1396833231629585236, 1527179557991190879],
                bytes.fromhex(
                    "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000002947dae18e4886ab"
                ),
                False,
            ),
        ],
    )

    assert (
        wrapper.pre_check_func(
            VAULT_ADDRESS,
            "exitPool(bytes32,address,address,(address[],uint256[],bytes,bool))",
            [
                bytes.fromhex(Balancer_rETH_WETH_PoolId[2:]),
                ZERO_ADDRESS,
                owner.address,
                (
                    [rETH, WETH],
                    [1396833231629585236, 1527179557991190879],
                    bytes.fromhex(
                        "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000002947dae18e4886ab"
                    ),
                    False,
                ),
            ],
        )
        is False
    )

    assert (
        wrapper.pre_check_func(
            VAULT_ADDRESS,
            "exitPool(bytes32,address,address,(address[],uint256[],bytes,bool))",
            [
                bytes.fromhex(Balancer_rETH_WETH_PoolId[2:]),
                owner.address,
                ZERO_ADDRESS,
                (
                    [rETH, WETH],
                    [1396833231629585236, 1527179557991190879],
                    bytes.fromhex(
                        "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000002947dae18e4886ab"
                    ),
                    False,
                ),
            ],
        )
        is False
    )

    assert (
        wrapper.pre_check_func(
            VAULT_ADDRESS,
            "exitPool(bytes32,address,address,(address[],uint256[],bytes,bool))",
            [
                bytes.fromhex(bb_a_USD_pool[2:]),
                owner.address,
                owner.address,
                (
                    [rETH, WETH],
                    [1396833231629585236, 1527179557991190879],
                    bytes.fromhex(
                        "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000002947dae18e4886ab"
                    ),
                    False,
                ),
            ],
        )
        is False
    )

    balancerAurarETHWETHAuthorizer.addPoolIds([Aura_rETH_WETH_PoolId])
    assert (
        Aura_rETH_WETH_PoolId
        in balancerAurarETHWETHAuthorizer.getPoolIdWhiteList.call()
    ) is True

    # Aura deposit
    # success
    assert wrapper.pre_check_func(
        BOOSTER_ADDRESS,
        "deposit(uint256,uint256,bool)",
        [
            Aura_rETH_WETH_PoolId,
            24345519060730088016,
            True,
        ],
    )

    assert (
        wrapper.pre_check_func(
            BOOSTER_ADDRESS,
            "deposit(uint256,uint256,bool)",
            [
                98,
                24345519060730088016,
                True,
            ],
        )
        is False
    )

    assert (
        wrapper.pre_check_func(
            BOOSTER_ADDRESS,
            "deposit(uint256,uint256,bool)",
            [
                Aura_rETH_WETH_PoolId,
                24345519060730088016,
                False,
            ],
        )
        is False
    )
