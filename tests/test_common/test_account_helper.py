from brownie import ZERO_ADDRESS
from tests.libtest import Operation, b32

TRANSFER_AMOUNT = 10000


def test_helper(
    wallet_wrapper,
    factory_wrapper,
    owner,
    FuncAuthorizer,
    ArgusRootAuthorizer,
    ArgusAccountHelper,
):
    # Prepare factory
    factory_wrapper.add_impl(
        FuncAuthorizer.deploy(ZERO_ADDRESS, ZERO_ADDRESS, {"from": owner})
    )
    factory = factory_wrapper.factory

    # Prepare cobo account
    account = wallet_wrapper.account
    root_auth = ArgusRootAuthorizer.deploy(owner, account, account, {"from": owner})
    wallet_wrapper.set_authorizer(root_auth)

    # Prepare helper.
    account_helper = ArgusAccountHelper.deploy({"from": owner})

    # Call helper.
    args = [factory.address, account.address, b32("FuncAuthorizer"), b32("tag")]

    wallet_wrapper.exec_transaction_ex(
        account_helper,
        "createAuthorizer(address,address,bytes32,bytes32)",
        args,
        flag=Operation.DELEGATE_CALL,
    )

    # Check result
    func_auth = FuncAuthorizer.at(
        factory.getCreate2Address(account, b32("FuncAuthorizer"), b32("tag")), account
    )
    assert func_auth.owner() == account
    assert func_auth.caller() == root_auth
    assert bytes(func_auth.tag()) == b32("tag")
