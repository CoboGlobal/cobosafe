from brownie import reverts
from brownie.network.account import Account
from tests.libtest import make_call, make_func_call

NETWORK_NAME = "development"

TRANSFER_AMOUNT = 10000


def test_smart(CoboSmartAccount, cobo_token, owner, delegate, receiver):
    smart = CoboSmartAccount.deploy(owner, {"from": owner})
    assert smart.owner() == owner

    owner.transfer(smart, TRANSFER_AMOUNT * 10)
    assert smart.balance() == TRANSFER_AMOUNT * 10

    before_balance = receiver.balance()

    tx = make_call(receiver, value=TRANSFER_AMOUNT)  # ETH transfer txn.

    # Single call.
    smart.execTransaction(tx)
    assert Account(receiver).balance() == before_balance + TRANSFER_AMOUNT

    # Multi call.
    smart.execTransactions([tx, tx])
    assert Account(receiver).balance() == before_balance + TRANSFER_AMOUNT * 3

    with reverts("E41"):  # INVALID_DELEGATE
        smart.execTransaction(tx, {"from": delegate})

    smart.addDelegate(delegate)
    with reverts("E44"):  # AUTHORIZER_NOT_SET
        smart.execTransaction(tx, {"from": delegate})

    cobo_token.transfer(smart, TRANSFER_AMOUNT)
    assert cobo_token.balanceOf(smart) == TRANSFER_AMOUNT

    tx = make_func_call(
        cobo_token.address,
        "transfer(address,uint256)",
        [receiver.address, TRANSFER_AMOUNT],
    )
    smart.execTransaction(tx)
    assert cobo_token.balanceOf(smart) == 0
    assert cobo_token.balanceOf(receiver) == TRANSFER_AMOUNT

    tx1 = make_func_call(
        cobo_token.address,
        "balanceOf(address)",
        [smart.address],
    )
    r1 = smart.execTransaction.call(tx1)

    tx2 = make_func_call(
        cobo_token.address,
        "balanceOf(address)",
        [receiver.address],
    )
    r2 = smart.execTransaction.call(tx2)

    r = smart.execTransactions.call([tx1, tx2, tx1])
    assert r[0] == r1
    assert r[1] == r2
    assert r[2] == r1
