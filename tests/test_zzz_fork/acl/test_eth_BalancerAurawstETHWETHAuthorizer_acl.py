from brownie import ZERO_ADDRESS
from tests.libtest import AuthorizerWrapper

# usage:
# 1、export WEB3_INFURA_PROJECT_ID=
# 2、brownie test tests/test_zzz_fork/acl/test_eth_BalancerAurawstETHWETHAuthorizer_acl.py --network mainnet-fork -s


NETWORK_NAME = "mainnet-fork"

VAULT_ADDRESS = "0xba12222222228d8ba445958a75a0704d566bf2c8"
BOOSTER_ADDRESS = "0xa57b8d98dae62b26ec3bcc4a365338157060b234"


Balancer_wstETH_WETH_PoolId = (
    "0x32296969ef14eb0c6d29669c550d4a0449130230000200000000000000000080"
)
bb_a_USD_pool = "0xa13a9247ea42d743238089903570127dda72fe4400000000000000000000035d"
Aura_wstETH_WETH_PoolId = 115

wstETH = "0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0"
B_stETH_STABLE = "0x32296969Ef14EB0c6d29669C550D4a0449130230"
WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"


def test_balancer_relayer(BalancerAurawstETHWETHAuthorizer, owner, delegate):
    balancerAurawstETHWETHAuthorizer = BalancerAurawstETHWETHAuthorizer.deploy(
        owner.address, owner.address, {"from": owner}
    )

    wrapper = AuthorizerWrapper(balancerAurawstETHWETHAuthorizer)

    balancerAurawstETHWETHAuthorizer.setBooster(BOOSTER_ADDRESS)
    balancerAurawstETHWETHAuthorizer.setVault(VAULT_ADDRESS)
    assert balancerAurawstETHWETHAuthorizer.BOOSTER_ADDRESS.call() == BOOSTER_ADDRESS
    assert balancerAurawstETHWETHAuthorizer.VAULT_ADDRESS.call() == VAULT_ADDRESS

    balancerAurawstETHWETHAuthorizer.addBalancerPoolIds([Balancer_wstETH_WETH_PoolId])
    assert (
        Balancer_wstETH_WETH_PoolId
        in balancerAurawstETHWETHAuthorizer.getBalancerPoolIdWhiteList.call()
    ) is True

    # Balancer joinPool
    assert wrapper.pre_check_func(
        VAULT_ADDRESS,
        "joinPool(bytes32,address,address,(address[],uint256[],bytes,bool))",
        [
            bytes.fromhex(Balancer_wstETH_WETH_PoolId[2:]),
            owner.address,
            owner.address,
            (
                [wstETH, WETH],
                [6722150446826063270, 0],
                bytes.fromhex(
                    "0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000065475f528f15661e00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000005d49e03745cd05a60000000000000000000000000000000000000000000000000000000000000000"
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
                bytes.fromhex(Balancer_wstETH_WETH_PoolId[2:]),
                ZERO_ADDRESS,
                owner.address,
                (
                    [wstETH, WETH],
                    [6722150446826063270, 0],
                    bytes.fromhex(
                        "0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000065475f528f15661e00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000005d49e03745cd05a60000000000000000000000000000000000000000000000000000000000000000"
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
                bytes.fromhex(Balancer_wstETH_WETH_PoolId[2:]),
                owner.address,
                ZERO_ADDRESS,
                (
                    [wstETH, WETH],
                    [6722150446826063270, 0],
                    bytes.fromhex(
                        "0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000065475f528f15661e00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000005d49e03745cd05a60000000000000000000000000000000000000000000000000000000000000000"
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
                    [wstETH, WETH],
                    [6722150446826063270, 0],
                    bytes.fromhex(
                        "0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000065475f528f15661e00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000005d49e03745cd05a60000000000000000000000000000000000000000000000000000000000000000"
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
            bytes.fromhex(Balancer_wstETH_WETH_PoolId[2:]),
            owner.address,
            owner.address,
            (
                [wstETH, WETH],
                [8796992973634728, 0],
                bytes.fromhex(
                    "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000224921ad5b74520000000000000000000000000000000000000000000000000000000000000000"
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
                bytes.fromhex(Balancer_wstETH_WETH_PoolId[2:]),
                ZERO_ADDRESS,
                owner.address,
                (
                    [wstETH, WETH],
                    [8796992973634728, 0],
                    bytes.fromhex(
                        "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000224921ad5b74520000000000000000000000000000000000000000000000000000000000000000"
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
                bytes.fromhex(Balancer_wstETH_WETH_PoolId[2:]),
                owner.address,
                ZERO_ADDRESS,
                (
                    [wstETH, WETH],
                    [8796992973634728, 0],
                    bytes.fromhex(
                        "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000224921ad5b74520000000000000000000000000000000000000000000000000000000000000000"
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
                    [wstETH, WETH],
                    [8796992973634728, 0],
                    bytes.fromhex(
                        "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000224921ad5b74520000000000000000000000000000000000000000000000000000000000000000"
                    ),
                    False,
                ),
            ],
        )
        is False
    )

    balancerAurawstETHWETHAuthorizer.addPoolIds([Aura_wstETH_WETH_PoolId])
    assert (
        Aura_wstETH_WETH_PoolId
        in balancerAurawstETHWETHAuthorizer.getPoolIdWhiteList.call()
    ) is True

    # Aura deposit
    # success
    assert wrapper.pre_check_func(
        BOOSTER_ADDRESS,
        "deposit(uint256,uint256,bool)",
        [
            Aura_wstETH_WETH_PoolId,
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
                Aura_wstETH_WETH_PoolId,
                24345519060730088016,
                False,
            ],
        )
        is False
    )
