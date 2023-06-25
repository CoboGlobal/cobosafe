from brownie import Wei, accounts
from tests.libtest import AuthorizerWrapper

NETWORK_NAME = "arbitrum-main-fork"
USDT = "0xfd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9"
GMX_GLP_REWARD_ROUTER = "0xB95DB5B167D75e6d04227CfFFA61069348d271F5"

ROUTER = "0xaBBc5F99639c9B6bCb58544ddf04EFA6802F4064"
ORDER_BOOK = "0x09f77E8A13De9a35a7231028187e9fD5DB8a2ACB"
WETH = "0x82af49447d8a07e3bd95bd0d56f35241523fbab1"
WBTC = "0x2f2a2543b76a4166549f7aab2e75bef0aefc5b0f"

POSITION_ROUTER = "0xb87a436B93fFE9D75c5cFA7bAcFff96430b09868"

NATIVE_ETH = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"


def test_glp_buy_sell(GmxGlpAuthorizer, owner):
    auth = GmxGlpAuthorizer.deploy(owner, owner, {"from": owner})

    auth_wrapper = AuthorizerWrapper(auth)

    auth.addPoolAddresses([USDT, NATIVE_ETH])

    def _check(func, data, require_true=True):
        if require_true:
            assert auth_wrapper.pre_check_func(GMX_GLP_REWARD_ROUTER, func, data)
        else:
            assert not auth_wrapper.pre_check_func(GMX_GLP_REWARD_ROUTER, func, data)

    _check(
        "mintAndStakeGlp(address,uint256,uint256,uint256)",
        [USDT, Wei("100 ether"), 0, 0],
    )

    _check(
        "unstakeAndRedeemGlp(address,uint256,uint256,address)",
        [USDT, Wei("100 ether"), 0, owner.address],
    )

    _check(
        "unstakeAndRedeemGlp(address,uint256,uint256,address)",
        [USDT, Wei("100 ether"), 0, owner.address],
    )

    _check(
        "mintAndStakeGlpETH(uint256,uint256)",
        [Wei("100 ether"), 0],
    )

    _check(
        "unstakeAndRedeemGlpETH(uint256,uint256,address)",
        [Wei("100 ether"), 0, owner.address],
    )

    _check(
        "unstakeAndRedeemGlpETH(uint256,uint256,address)",
        [Wei("100 ether"), 0, str(accounts[1])],
        require_true=False,
    )

    auth.removePoolAddresses([USDT])

    _check(
        "mintAndStakeGlp(address,uint256,uint256,uint256)",
        [USDT, Wei("100 ether"), 0, 0],
        require_true=False,
    )
