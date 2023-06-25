from tests.libtest import AuthorizerWrapper
from web3 import HTTPProvider, Web3

NETWORK_NAME = "mainnet-fork"

WETH = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
ROUTER = "0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57"

ETH = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"
STG = "0xaf5191b0de278c7286d6c7cc6ab6bb8a73ba2cd6"
USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
USDT = "0xdac17f958d2ee523a2206206994597c13d831ec7"
LBR = "0xf1182229b71e79e504b1d2bf076c15a277311e05"
STETH = "0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84"
HYPC = "0xea7b7dc089c9a4a916b5a7a37617f59fd54e37e4"
LILY = "0xd841382aac5782fd9c6a516d6b752ee8e6527559"

SimpleSwapSig = "simpleSwap((address,address,uint256,uint256,uint256,address[],bytes,uint256[],uint256[],address,address,uint256,bytes,uint256,bytes16))"


def test_paraswap_acl(ParaswapBotAuthorizer, owner):
    web3 = Web3(HTTPProvider("https://rpc.ankr.com/eth"))

    auth = ParaswapBotAuthorizer.deploy(owner, owner, {"from": owner})
    wrapper = AuthorizerWrapper(auth)

    def test_swap_tx(txid, in_token, out_token):
        tx = web3.eth.get_transaction(txid)
        print(wrapper.pre_check_raw_tx(tx, True))
        assert not wrapper.pre_check_raw_tx(tx)

        auth.addSwapInTokens([in_token])
        auth.addSwapOutTokens([out_token])
        print(wrapper.pre_check_raw_tx(tx, True))
        assert wrapper.pre_check_raw_tx(tx)

    # SimpleSwap
    test_swap_tx(
        "0x5307ce12e6252aaea5cd40b845bf0a10ecdfdb3849a5cf388c67e285379e54cf", STG, ETH
    )

    # SimpleBuy
    test_swap_tx(
        "0xafcdfda106f18a61339630f0475164dcb478bc7e1956c27a1013238f1a29b7ac", ETH, USDC
    )

    # MultiSwap
    test_swap_tx(
        "0x931f1ace658a3b788f2954bf76d03fd75fa6ec0728e7f7994d84b16a7f10a4a0", USDT, LBR
    )

    # MegaSwap
    test_swap_tx(
        "0x3e0ab6db5ec3c8f05a80ddab6857d97b5c4154a37879564930004c462e949071", STETH, ETH
    )

    # SwapUni
    test_swap_tx(
        "0xdeefd143100d096eb9402b2ff89764a4bf18a106d38dfe60b34ca7fd4159560a", HYPC, ETH
    )

    # BuyUni
    test_swap_tx(
        "0x7b0c3f245834edbe867325dda781a1820e7dfe3a7a0f93e9704f0b7cf03808f3", ETH, LILY
    )

    # From SimpleSwap_STG_ETH
    simple_data = [
        "0xaf5191b0de278c7286d6c7cc6ab6bb8a73ba2cd6",
        "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
        400000000000000000000,
        137272131942834766,
        137961941651090217,
        (
            "0xe592427a0aece92de3edee1f18e0157c05861564",
            "0xdef171fe48cf0115b1d80b88dc8eab59176fee57",
        ),
        b"\xc0K\x8dY\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00 \x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xa0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xde\xf1q\xfeH\xcf\x01\x15\xb1\xd8\x0b\x88\xdc\x8e\xabY\x17o\xeeW\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00dm\xbbi\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x15\xaf\x1dx\xb5\x8c@\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00+\xafQ\x91\xb0\xde'\x8cr\x86\xd6\xc7\xccj\xb6\xbb\x8as\xba,\xd6\x00\x0b\xb8\xc0*\xaa9\xb2#\xfe\x8d\n\x0e\\O'\xea\xd9\x08<ul\xc2\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xe1\x82\x9c\xfe\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xc0*\xaa9\xb2#\xfe\x8d\n\x0e\\O'\xea\xd9\x08<ul\xc2",
        (0, 292, 328),
        (0, 0),
        "0x0000000000000000000000000000000000000000",
        "0x08a3c2a819e3de7aca384c798269b3ce1cd0e437",
        452312848583266388373324160190187140051835877600158453279131187530910662656,
        b"",
        1684329802,
        b"kB\x95I\\\x18C\x1c\x81Y\xe9\xe7\xcc\x1a\xcc\xba",
    ]

    assert wrapper.pre_check_func(ROUTER, SimpleSwapSig, [simple_data])

    simple_data[9] = WETH  # Change beneficiary
    assert not wrapper.pre_check_func(ROUTER, SimpleSwapSig, [simple_data])
