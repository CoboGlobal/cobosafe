from brownie import ZERO_ADDRESS
from tests.libtest import AuthorizerWrapper

# usage:
# 1、export WEB3_INFURA_PROJECT_ID=
# 2、brownie test tests/test_zzz_fork/acl/test_eth_BalancerAuraRDaiAuthorizer_acl.py --network mainnet-fork -s


NETWORK_NAME = "mainnet-fork"

VAULT_ADDRESS = "0xba12222222228d8ba445958a75a0704d566bf2c8"
BOOSTER_ADDRESS = "0xa57b8d98dae62b26ec3bcc4a365338157060b234"


TOTAL_AMOUNT = 50 * 10**18
SUCC_AMOUNT = 1 * 10**18

USDC_AMOUNT = 5000 * 10**6
BBAUSDC_AMOUNT = 10000000 * 10**18

Balancer_R_DAI_PoolId = (
    "0x20a61b948e33879ce7f23e535cc7baa3bc66c5a9000000000000000000000555"
)
bb_a_USD_pool = "0xa13a9247ea42d743238089903570127dda72fe4400000000000000000000035d"
Aura_R_DAI_PoolId = 97

R = "0x183015a9bA6fF60230fdEaDc3F43b3D788b13e21"
R_DAI_BLP = "0x20a61B948E33879ce7F23e535CC7BAA3BC66c5a9"
DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F"


def test_balancer_relayer(BalancerAuraRDaiAuthorizer, owner, delegate):
    balancerAuraRDaiAuthorizer = BalancerAuraRDaiAuthorizer.deploy(
        owner.address, owner.address, {"from": owner}
    )

    wrapper = AuthorizerWrapper(balancerAuraRDaiAuthorizer)

    balancerAuraRDaiAuthorizer.setBooster(BOOSTER_ADDRESS)
    balancerAuraRDaiAuthorizer.setVault(VAULT_ADDRESS)
    assert balancerAuraRDaiAuthorizer.BOOSTER_ADDRESS.call() == BOOSTER_ADDRESS
    assert balancerAuraRDaiAuthorizer.VAULT_ADDRESS.call() == VAULT_ADDRESS

    balancerAuraRDaiAuthorizer.addBalancerPoolIds([Balancer_R_DAI_PoolId])
    assert (
        Balancer_R_DAI_PoolId
        in balancerAuraRDaiAuthorizer.getBalancerPoolIdWhiteList.call()
    ) is True

    # Balancer joinPool
    assert wrapper.pre_check_func(
        VAULT_ADDRESS,
        "joinPool(bytes32,address,address,(address[],uint256[],bytes,bool))",
        [
            bytes.fromhex(Balancer_R_DAI_PoolId[2:]),
            owner.address,
            owner.address,
            (
                [R, R_DAI_BLP, DAI],
                [254636157874759962, 0, 147416191090204335850],
                bytes.fromhex(
                    "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000007fd4ba73645d71ac200000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000388a63c8918691a000000000000000000000000000000000000000000000007fdcf84c088bbdeea"
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
                bytes.fromhex(Balancer_R_DAI_PoolId[2:]),
                ZERO_ADDRESS,
                owner.address,
                (
                    [R, R_DAI_BLP, DAI],
                    [254636157874759962, 0, 147416191090204335850],
                    bytes.fromhex(
                        "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000007fd4ba73645d71ac200000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000388a63c8918691a000000000000000000000000000000000000000000000007fdcf84c088bbdeea"
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
                bytes.fromhex(Balancer_R_DAI_PoolId[2:]),
                owner.address,
                ZERO_ADDRESS,
                (
                    [R, R_DAI_BLP, DAI],
                    [254636157874759962, 0, 147416191090204335850],
                    bytes.fromhex(
                        "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000007fd4ba73645d71ac200000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000388a63c8918691a000000000000000000000000000000000000000000000007fdcf84c088bbdeea"
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
                    [R, R_DAI_BLP, DAI],
                    [254636157874759962, 0, 147416191090204335850],
                    bytes.fromhex(
                        "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000007fd4ba73645d71ac200000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000388a63c8918691a000000000000000000000000000000000000000000000007fdcf84c088bbdeea"
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
            bytes.fromhex(Balancer_R_DAI_PoolId[2:]),
            owner.address,
            owner.address,
            (
                [R, R_DAI_BLP, DAI],
                [254636157874759962, 0, 147416191090204335850],
                bytes.fromhex(
                    "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000007fd4ba73645d71ac200000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000388a63c8918691a000000000000000000000000000000000000000000000007fdcf84c088bbdeea"
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
                bytes.fromhex(Balancer_R_DAI_PoolId[2:]),
                ZERO_ADDRESS,
                owner.address,
                (
                    [R, R_DAI_BLP, DAI],
                    [254636157874759962, 0, 147416191090204335850],
                    bytes.fromhex(
                        "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000007fd4ba73645d71ac200000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000388a63c8918691a000000000000000000000000000000000000000000000007fdcf84c088bbdeea"
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
                bytes.fromhex(Balancer_R_DAI_PoolId[2:]),
                owner.address,
                ZERO_ADDRESS,
                (
                    [R, R_DAI_BLP, DAI],
                    [254636157874759962, 0, 147416191090204335850],
                    bytes.fromhex(
                        "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000007fd4ba73645d71ac200000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000388a63c8918691a000000000000000000000000000000000000000000000007fdcf84c088bbdeea"
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
                    [R, R_DAI_BLP, DAI],
                    [254636157874759962, 0, 147416191090204335850],
                    bytes.fromhex(
                        "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000007fd4ba73645d71ac200000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000388a63c8918691a000000000000000000000000000000000000000000000007fdcf84c088bbdeea"
                    ),
                    False,
                ),
            ],
        )
        is False
    )

    balancerAuraRDaiAuthorizer.addPoolIds([Aura_R_DAI_PoolId])
    assert (
        Aura_R_DAI_PoolId in balancerAuraRDaiAuthorizer.getPoolIdWhiteList.call()
    ) is True

    # Aura deposit
    # success
    assert wrapper.pre_check_func(
        BOOSTER_ADDRESS,
        "deposit(uint256,uint256,bool)",
        [
            Aura_R_DAI_PoolId,
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
                Aura_R_DAI_PoolId,
                24345519060730088016,
                False,
            ],
        )
        is False
    )
