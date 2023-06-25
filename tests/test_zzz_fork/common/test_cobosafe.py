from brownie import reverts
from tests.libtest import make_call

NETWORK_NAME = "bsc-main-fork"
TRANSFER_AMOUNT = 10000


def test_cobosafe(
    CoboSafeAccount, DummyAuthorizer, owner, delegate, receiver, gnosis_safe_wrapper
):
    safe = gnosis_safe_wrapper.safe.address

    cobosafe = CoboSafeAccount.deploy(safe, {"from": delegate})
    assert cobosafe.owner() == safe
    cobosafe.addDelegate(delegate, {"from": safe})

    gnosis_safe_wrapper.enable_module(cobosafe.address)

    owner.transfer(safe, TRANSFER_AMOUNT * 10)

    tx = make_call(receiver, value=TRANSFER_AMOUNT)  # ETH transfer txn.

    with reverts("E44"):
        cobosafe.execTransaction(tx, {"from": delegate})

    auth = DummyAuthorizer.deploy(safe, cobosafe, {"from": delegate})

    gnosis_safe_wrapper.exec_transaction_ex(
        cobosafe.address, "setAuthorizer(address)", [auth.address]
    )

    before = receiver.balance()
    cobosafe.execTransaction(tx, {"from": delegate})
    assert receiver.balance() - before == TRANSFER_AMOUNT
