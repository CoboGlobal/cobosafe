from tests.libtest import AuthorizerWrapper

NETWORK_NAME = "arbitrum-main-fork"
AGGREATOR = "0x1111111254eeb25477b68fb85ed929f73a960582"
USDT = "0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9"
USDC = "0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8"
WETH = "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1"
GMX = "0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a"
DAI = "0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1"


def test_1inchV5(OneinchV5Authorizer, owner, delegate):
    inchV5Authorizer = OneinchV5Authorizer.deploy(
        owner.address, owner.address, {"from": owner}
    )

    wrapper = AuthorizerWrapper(inchV5Authorizer)

    # swap USDT to USDC
    inchV5Authorizer.addSwapInTokens([USDT])
    inchV5Authorizer.addSwapOutTokens([USDC])

    assert wrapper.pre_check_func(
        AGGREATOR,
        "uniswapV3Swap(uint256,uint256,uint256[])",
        [
            1000000,
            0,
            [
                802762978358017323376512008816365767291430407793
            ],  # 0x8c9D230D45d6CfeE39a6680Fb7CB7E8DE7Ea8E71
        ],
    )

    inchV5Authorizer.removeSwapInTokens([USDT])
    assert (
        wrapper.pre_check_func(
            AGGREATOR,
            "uniswapV3Swap(uint256,uint256,uint256[])",
            [
                1000000,
                0,
                [802762978358017323376512008816365767291430407793],
            ],
        )
        is False
    )

    inchV5Authorizer.addSwapInTokens([USDT])
    inchV5Authorizer.removeSwapOutTokens([USDC])
    assert (
        wrapper.pre_check_func(
            AGGREATOR,
            "uniswapV3Swap(uint256,uint256,uint256[])",
            [
                1000000,
                0,
                [802762978358017323376512008816365767291430407793],
            ],
        )
        is False
    )

    # swap DAI to GMX
    inchV5Authorizer.addSwapInTokens([DAI])
    inchV5Authorizer.addSwapOutTokens([GMX])
    assert wrapper.pre_check_func(
        AGGREATOR,
        "uniswapV3Swap(uint256,uint256,uint256[])",
        [
            6201385034225769472,
            98079753518064330,
            [
                57896044618658097711785492504608775381615833223984669687443888320883071627252,
                1028820836078621013649502902537592844810475277745,
            ],
        ],
    )

    inchV5Authorizer.removeSwapInTokens([DAI])
    assert (
        wrapper.pre_check_func(
            AGGREATOR,
            "uniswapV3Swap(uint256,uint256,uint256[])",
            [
                6201385034225769472,
                98079753518064330,
                [
                    57896044618658097711785492504608775381615833223984669687443888320883071627252,
                    1028820836078621013649502902537592844810475277745,
                ],
            ],
        )
        is False
    )

    inchV5Authorizer.addSwapInTokens([DAI])
    inchV5Authorizer.removeSwapOutTokens([GMX])
    assert (
        wrapper.pre_check_func(
            AGGREATOR,
            "uniswapV3Swap(uint256,uint256,uint256[])",
            [
                6201385034225769472,
                98079753518064330,
                [
                    57896044618658097711785492504608775381615833223984669687443888320883071627252,
                    1028820836078621013649502902537592844810475277745,
                ],
            ],
        )
        is False
    )
