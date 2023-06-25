import warnings

import eth_abi
from brownie import ZERO_ADDRESS, chain, web3
from hexbytes import HexBytes

# --wallet.mnemonic brownie
DEFAULT_OWNER = "0x66aB6D9362d4F35596279692F0251Db635165871"  # accounts[0]
DEFAULT_DELEGATE = "0x33A4622B82D4c04a53e170c638B944ce27cffce3"  # accounts[1]
DELEGATE_ROLE = eth_abi.encode(["address"], [DEFAULT_DELEGATE])


def func_selector(func_signature: str) -> HexBytes:
    return web3.keccak(text=func_signature)[:4]


def abi_encode_with_sig(func_signature, args=[]) -> HexBytes:
    selector = func_selector(func_signature)
    arg_sig = func_signature[func_signature.index("(") :]

    with warnings.catch_warnings():
        warnings.filterwarnings("ignore", category=DeprecationWarning)
        return selector + eth_abi.encode_single(arg_sig, args)

    # Can NOT replace with eth_abi.encode([arg_sig], [args]) due to dynamic paras abi-encoding.
    # eth_abi.encode will treat `arg_sig` as a tuple, not args list.
    # but encode_single warns DeprecationWarning, catch it.


# struct CallData {
#     uint256 flag; // 0x1 delegate call, 0x0 call.
#     address to;
#     uint256 value;
#     bytes data;  // calldata
#     bytes hint;
#     bytes extra; // for future support: signatures etc.
# }


def make_call(to, data=b"", value=0, flag=0, hint=b"", extra=b""):
    # struct CallData
    return [flag, to, value, data, hint, extra]


def make_func_call(to, func_sig, args, value=0, flag=0, hint=b"", extra=b""):
    data = abi_encode_with_sig(func_sig, args)
    return make_call(to, data, value, flag, hint, extra)


# struct TransactionData {
#     address from; // Sender who performs the transaction a.k.a wallet address.
#     address delegate; // Delegate who calls executeTransactions().
#     bytes32[] roles; // Roles authenticated by RoleManager.

#     // Same as CallData
#     uint256 flag; // 0x1 delegate call, 0x0 call.
#     address to;
#     uint256 value;
#     bytes data;  // calldata
#     bytes hint;
#     bytes extra;
# }


def make_tx(
    to=ZERO_ADDRESS,
    data=b"",
    value=0,
    flag=0,
    delegate=DEFAULT_DELEGATE,
    sender=DEFAULT_OWNER,
    hint=b"",
    extra=b"",
):
    # struct TransactionData
    return [sender, delegate, flag, to, value, data, hint, extra]


def make_tx_from_raw_tx(tx, delegate=DEFAULT_DELEGATE, hint=b"", extra=b""):
    return make_tx(
        tx.to,
        tx.input,
        tx.value,
        delegate=delegate,
        sender=tx["from"],
        hint=hint,
        extra=extra,
    )


def make_func_tx(func, args, value=0, to=ZERO_ADDRESS):
    data = abi_encode_with_sig(func, args)
    return make_tx(to=to, data=data, value=value)


def b32(name):
    if type(name) is str:
        name = bytes(name, "ascii")

    return eth_abi.encode(["bytes32"], [name])


def print_hex(data, align_bytes=32, skip=4):
    if type(data) is bytes:
        data = data.hex()

    if data.startswith("0x"):
        data = data[2:]

    if skip:
        data = data[skip * 2 :]

    offset = 0
    while data:
        print("%#5x" % offset, data[: align_bytes * 2])
        data = data[align_bytes * 2 :]
        offset += align_bytes


class AutoReset(object):
    def __enter__(self):
        chain.snapshot()

    def __exit__(self, type, value, traceback):
        chain.revert()


auto_reset = AutoReset()
