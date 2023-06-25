from brownie import chain
from tests.libtest import AuthorizerWrapper

NETWORK_NAME = "bsc-main-fork"

ROUTER_ADDRESS = "0x10ED43C718714eb63d5aA57B78B54704E256024E"
SMART_ROUTER_ADDRESS = "0x2f22e47CA7C5e07F77785f616cEeE80c5E84127C"

BNB_ADDRESS = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"

WBNB_ADDRESS = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c"
WBNB_HOLDER = "0x0ed7e52944161450477ee417de9cd3a859b14fd0"

BUSD_ADDRESS = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56"
BUSD_HOLDER = "0xF977814e90dA44bFA03b6295A0616a897441aceC"

USDC_ADDRESS = "0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d"

WBNB_AMOUNT = 500 * 10**18
BUSD_AMOUNT = 10000 * 10**18


def test_pancakeswap(PancakeSwapAuthorizer, owner):
    pancakeSwapAuthorizer = PancakeSwapAuthorizer.deploy(
        owner.address, owner.address, {"from": owner}
    )

    wrapper = AuthorizerWrapper(pancakeSwapAuthorizer)

    pancakeSwapAuthorizer.addSwapInTokens([BNB_ADDRESS, WBNB_ADDRESS])
    pancakeSwapAuthorizer.addSwapOutTokens([BUSD_ADDRESS])

    assert wrapper.pre_check_func(
        ROUTER_ADDRESS,
        "swapETHForExactTokens(uint256,address[],address,uint256)",
        [
            200 * 10**18,
            [WBNB_ADDRESS, BUSD_ADDRESS],
            owner.address,
            chain.time() + 60,
        ],
        value=2 * 10**18,
    )

    assert wrapper.pre_check_func(
        ROUTER_ADDRESS,
        "swapExactETHForTokens(uint256,address[],address,uint256)",
        [
            100 * 10**18,
            [WBNB_ADDRESS, BUSD_ADDRESS],
            owner.address,
            chain.time() + 60,
        ],
        value=1 * 10**18,
    )

    pancakeSwapAuthorizer.removeSwapInTokens([BNB_ADDRESS, WBNB_ADDRESS])
    pancakeSwapAuthorizer.removeSwapOutTokens([BUSD_ADDRESS])

    pancakeSwapAuthorizer.addSwapInTokens([BUSD_ADDRESS])
    pancakeSwapAuthorizer.addSwapOutTokens([WBNB_ADDRESS, BNB_ADDRESS])

    assert wrapper.pre_check_func(
        ROUTER_ADDRESS,
        "swapExactTokensForETH(uint256,uint256,address[],address,uint256)",
        [
            1000 * 10**18,
            1 * 10**18,
            [BUSD_ADDRESS, WBNB_ADDRESS],
            owner.address,
            chain.time() + 60,
        ],
    )

    assert wrapper.pre_check_func(
        ROUTER_ADDRESS,
        "swapTokensForExactETH(uint256,uint256,address[],address,uint256)",
        [
            2 * 10**18,
            1000 * 10**18,
            [BUSD_ADDRESS, WBNB_ADDRESS],
            owner.address,
            chain.time() + 60,
        ],
    )
    pancakeSwapAuthorizer.removeSwapInTokens([BUSD_ADDRESS])
    pancakeSwapAuthorizer.removeSwapOutTokens([WBNB_ADDRESS, BNB_ADDRESS])

    pancakeSwapAuthorizer.addSwapInTokens([WBNB_ADDRESS])
    pancakeSwapAuthorizer.addSwapOutTokens([BUSD_ADDRESS])
    assert wrapper.pre_check_func(
        ROUTER_ADDRESS,
        "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)",
        [
            1 * 10**18,
            100 * 10**18,
            [WBNB_ADDRESS, BUSD_ADDRESS],
            owner.address,
            chain.time() + 60,
        ],
    )

    pancakeSwapAuthorizer.removeSwapInTokens([WBNB_ADDRESS])
    pancakeSwapAuthorizer.removeSwapOutTokens([BUSD_ADDRESS])

    pancakeSwapAuthorizer.addSwapInTokens([BUSD_ADDRESS])
    pancakeSwapAuthorizer.addSwapOutTokens([WBNB_ADDRESS])
    assert wrapper.pre_check_func(
        ROUTER_ADDRESS,
        "swapTokensForExactTokens(uint256,uint256,address[],address,uint256)",
        [
            2 * 10**18,
            1000 * 10**18,
            [BUSD_ADDRESS, WBNB_ADDRESS],
            owner.address,
            chain.time() + 60,
        ],
    )
    pancakeSwapAuthorizer.removeSwapInTokens([BUSD_ADDRESS])
    pancakeSwapAuthorizer.removeSwapOutTokens([WBNB_ADDRESS])

    pancakeSwapAuthorizer.addSwapInTokens([WBNB_ADDRESS])
    pancakeSwapAuthorizer.addSwapOutTokens([BUSD_ADDRESS])
    assert wrapper.pre_check_func(
        SMART_ROUTER_ADDRESS,
        "swap(address,address,uint256,uint256,uint8)",
        [WBNB_ADDRESS, BUSD_ADDRESS, 2 * 10**18, 100 * 10**18, 1],
    )
    pancakeSwapAuthorizer.removeSwapInTokens([WBNB_ADDRESS])
    pancakeSwapAuthorizer.removeSwapOutTokens([BUSD_ADDRESS])

    pancakeSwapAuthorizer.addSwapInTokens([WBNB_ADDRESS])
    pancakeSwapAuthorizer.addSwapOutTokens([USDC_ADDRESS])
    assert wrapper.pre_check_func(
        SMART_ROUTER_ADDRESS,
        "swapMulti(address[],uint256,uint256,uint8[])",
        [
            [WBNB_ADDRESS, BUSD_ADDRESS, USDC_ADDRESS],
            2 * 10**18,
            100 * 10**18,
            [1, 0],
        ],
    )
    pancakeSwapAuthorizer.removeSwapInTokens([WBNB_ADDRESS])
    pancakeSwapAuthorizer.removeSwapOutTokens([USDC_ADDRESS])

    pancakeSwapAuthorizer.addSwapInTokens([BNB_ADDRESS])
    pancakeSwapAuthorizer.addSwapOutTokens([USDC_ADDRESS])
    assert wrapper.pre_check_func(
        SMART_ROUTER_ADDRESS,
        "swapMulti(address[],uint256,uint256,uint8[])",
        [
            [BNB_ADDRESS, BUSD_ADDRESS, USDC_ADDRESS],
            2 * 10**18,
            100 * 10**18,
            [1, 0],
        ],
        value=2 * 10**18,
    )
    pancakeSwapAuthorizer.removeSwapInTokens([BNB_ADDRESS])
    pancakeSwapAuthorizer.removeSwapOutTokens([USDC_ADDRESS])
