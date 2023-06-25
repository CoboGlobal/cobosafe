from brownie import ZERO_ADDRESS
from tests.libtest import AuthorizerWrapper, auto_reset
from web3 import HTTPProvider, Web3

NETWORK_NAME = "mainnet-fork"

AGGREATOR = "0x1111111254eeb25477b68fb85ed929f73a960582"
ETH = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"
WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"

USDT = "0xdac17f958d2ee523a2206206994597c13d831ec7"
USDC = "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"


def test_add_remove(OneinchV5Authorizer, owner):
    inchV5Authorizer = OneinchV5Authorizer.deploy(
        owner.address, owner.address, {"from": owner}
    )

    inchV5Authorizer.addSwapInTokens([USDT])
    assert inchV5Authorizer.hasSwapInToken.call(USDT) is True
    assert USDT in inchV5Authorizer.getSwapInTokens.call()

    inchV5Authorizer.removeSwapInTokens([USDT])
    assert inchV5Authorizer.hasSwapInToken.call(USDT) is False

    inchV5Authorizer.addSwapOutTokens([USDT])
    assert inchV5Authorizer.hasSwapOutToken.call(USDT) is True
    assert USDT in inchV5Authorizer.getSwapOutTokens.call()

    inchV5Authorizer.removeSwapOutTokens([USDT])
    assert inchV5Authorizer.hasSwapOutToken.call(USDT) is False


web3 = Web3(HTTPProvider("https://rpc.ankr.com/eth"))


def check_tx(txid, in_token, out_token, wrapper, auth):
    with auto_reset:
        tx = web3.eth.get_transaction(txid)
        print(wrapper.pre_check_raw_tx(tx, True))
        assert not wrapper.pre_check_raw_tx(tx)

        auth.addSwapInTokens([in_token])
        auth.addSwapOutTokens([out_token])
        print(wrapper.pre_check_raw_tx(tx, True))
        assert wrapper.pre_check_raw_tx(tx)


def test_check_swap(OneinchV5Authorizer, owner):
    auth = OneinchV5Authorizer.deploy(owner.address, owner.address, {"from": owner})
    wrapper = AuthorizerWrapper(auth)

    def _check_tx(txid, in_token, out_token):
        check_tx(txid, in_token, out_token, wrapper, auth)

    # swap ETH - WETH
    _check_tx(
        "0xd7c555715303797706e6e018bda80e645565b56e10b5c3fed6aebb7b5e329f89", ETH, WETH
    )

    args = [
        "0x1136b25047e142fa3018184793aec68fbb173ce4",  # executor
        (
            "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",  # desc.srcToken
            "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",  # desc.dstToken
            "0x1136b25047e142fa3018184793aec68fbb173ce4",  # desc.srcReceiver
            ZERO_ADDRESS,  # desc.dstReceiver
            101177133394218478,
            100458775747119526,
            0,
        ),
        b"",  # permit
        bytes.fromhex(
            "00000000000000000000000000000000000000000000000000006800001a4061c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2d0e30db080206c4eca27c02aaa39b223fe8d0a0e5c4f27ead9083c756cc21111111254eeb25477b68fb85ed929f73a96058200000000000000000000000000000000000000000000000001677411175acdee"
        ),
    ]

    # Invalid desc.dstReceiver
    assert not wrapper.pre_check_func(
        AGGREATOR,
        "swap(address,(address,address,address,address,uint256,uint256,uint256),bytes,bytes)",
        args,
        value=101177133394218478,
    )

    # unoswap ETH - BIT
    _check_tx(
        "0x13a443525389b155b085322318b0d47049291bb12f99793e7a805210a84e68a4",
        ETH,
        "0x1a4b46696b2bb4794eb3d4c26f1c55f9170fa4c5",
    )

    # unoswap DAI - ETH
    _check_tx(
        "0xe33427cf23d8b7a0c36fa26eef29f7ced8f17e8146852d4e9adcfbf1fd33b542",
        "0x6b175474e89094c44da98b954eedeac495271d0f",
        ETH,
    )

    # uniswapV3Swap ETH - PSYOP
    _check_tx(
        "0xd9b2b50ec8223c69925d6ef2bfa11c44bf111081fad45b7c4cf68d78c80bdf41",
        ETH,
        "0x3007083eaa95497cd6b2b809fb97b6a30bdf53d3",
    )

    # uniswapV3Swap  USDC - RFD
    _check_tx(
        "0x4b4a224300823ae7f44a782d128c8828bfa0e3ff9880c67d966e2c379561e0a6",
        "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
        "0x955d5c14c8d4944da1ea7836bd44d54a8ec35ba1",
    )

    # uniswapV3Swap PET - ETH
    _check_tx(
        "0xb724e35c99802de4ce9387f7603f00e641f33d804e5f5a245ae2c15ebf4c2028",
        "0xb870679a7fa65b924026f496de7f27c1dd0e5c5f",
        ETH,
    )


def test_check_swap2(OneinchV5Authorizer, owner):
    auth = OneinchV5Authorizer.deploy(owner.address, owner.address, {"from": owner})
    wrapper = AuthorizerWrapper(auth)

    def _check_tx(txid, in_token, out_token):
        check_tx(txid, in_token, out_token, wrapper, auth)

    # clipperSwap ETH - USDT
    _check_tx(
        "0x6a6a9213d16bbfaae534ec37ecee3f3af8406c76251b7eb3b66fd1dd65e67f3a", ETH, USDT
    )

    # fillOrder POLY - USDT
    _check_tx(
        "0x14100bb23544a509c76444e8d20f04cd100b5f6bfddf6a100d3653b6a189269b",
        "0x9992ec3cf6a55b00978cddf2b27bc6882d88d1ec",  # POLY
        USDT,
    )

    # fillOrderRFQ
    _check_tx(
        "0xb526e4f57131afb84ca7f81447dd233302eacef7030d190724488b9a96eb3f2d", USDC, ETH
    )

    # fillOrderRFQCompact
    _check_tx(
        "0x90c22ff7b0122970457b6f684305a59f7db7b050b5774deefdbccc832e7cad1f",
        "0x6982508145454Ce325dDbE47a25d4ec3d2311933",
        ETH,
    )
