from tests.libtest import AuthorizerWrapper
from web3 import HTTPProvider, Web3

NETWORK_NAME = "mainnet-fork"

ROUTER = "0xdef1c0ded9bec7f1a1670819833240f027b25eff"


def test_zerox_swap(ZeroXBotAuthorizer, owner):
    web3 = Web3(HTTPProvider("https://rpc.ankr.com/eth"))

    auth = ZeroXBotAuthorizer.deploy(owner, owner, {"from": owner})
    wrapper = AuthorizerWrapper(auth)

    def test_swap_tx(txid, in_token, out_token):
        tx = web3.eth.get_transaction(txid)
        print(wrapper.pre_check_raw_tx(tx, True))
        assert not wrapper.pre_check_raw_tx(tx)

        auth.addSwapInTokens([in_token])
        auth.addSwapOutTokens([out_token])
        print(wrapper.pre_check_raw_tx(tx, True))
        assert wrapper.pre_check_raw_tx(tx)

    # Invalid contract.
    assert not wrapper.pre_check_func(
        "0x72e4f9F808C49A2a61dE9C5896298920Dc4EEEa9",
        "sellToUniswap(address[],uint256,uint256,bool)",
        [[], 1, 1, True],
    )

    # Invalid method.
    assert not wrapper.pre_check_func(
        "0xdef1c0ded9bec7f1a1670819833240f027b25eff", "foo()", []
    )

    # transformERC20
    test_swap_tx(
        "0x84465f777bbc77e00e21633705e4b0d1ae234f53ffdbd57a4d997177e3fda7e1",
        "0x72e4f9F808C49A2a61dE9C5896298920Dc4EEEa9",
        "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE",
    )

    # sellToUniswap
    test_swap_tx(
        "0x0786b1f01fe9d7c26dd7e24302128643ded36ee5911c90e99dcb7745fad5a7c8",
        "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
        "0x0D58df0929b6bAf8ED231f3Fa672F0e5DcD665f7",
    )

    # sellTokenForTokenToUniswapV3
    test_swap_tx(
        "0xf07699d9512402fbc680b1457ca4608bd34f763bf555c887131d9745a645a2ee",
        "0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39",
        "0xdAC17F958D2ee523a2206206994597C13D831ec7",
    )

    # sellEthForTokenToUniswapV3
    test_swap_tx(
        "0xcbbee04f54a9a681bed88a79c8e881efa63aa0b6ea0a10823bc22572d4fe10c4",
        "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE",
        "0xfc4913214444aF5c715cc9F7b52655e788A569ed",
    )

    # sellTokenForEthToUniswapV3
    test_swap_tx(
        "0xb1d932e24d27ce5f6d48d1900226138248444df9dba23f9a7323055ee5892773",
        "0x4F9254C83EB525f9FCf346490bbb3ed28a81C667",
        "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE",
    )

    web3 = Web3(HTTPProvider("https://rpc.ankr.com/bsc"))
    # sellToPancakeSwap
    test_swap_tx(
        "0xdba0367ca64c2f1c3446643a5d1a64759814ee2d353fd2c6781af4fb5195c713",
        "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE",
        "0x48c3320C07b92C1783C84dE67d7a2d017B7238Ee",
    )
