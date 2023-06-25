from brownie import ZERO_ADDRESS
from tests.libtest import Operation, b32

NETWORK_NAME = "bsc-main-fork"
TRANSFER_AMOUNT = 10000


def test_init_argus(
    gnosis_safe_wrapper,
    factory_wrapper,
    owner,
    CoboSafeAccount,
    FlatRoleManager,
    ArgusRootAuthorizer,
    ArgusAccountHelper,
    ArgusViewHelper,
):
    factory_wrapper.add_impl(CoboSafeAccount.deploy(ZERO_ADDRESS, {"from": owner}))
    factory_wrapper.add_impl(FlatRoleManager.deploy(ZERO_ADDRESS, {"from": owner}))
    factory_wrapper.add_impl(
        ArgusRootAuthorizer.deploy(
            ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, {"from": owner}
        )
    )

    view_helper = ArgusViewHelper.deploy({"from": owner})
    account_helper = ArgusAccountHelper.deploy({"from": owner})

    factory = factory_wrapper.factory
    safe = gnosis_safe_wrapper.safe

    r = view_helper.getCoboSafes(factory, safe)
    assert len(r) == 0

    gnosis_safe_wrapper.exec_transaction_ex(
        account_helper,
        "initArgus(address,bytes32)",
        [factory.address, b32("salt")],
        call_type=Operation.DELEGATE_CALL,
    )
    r = view_helper.getCoboSafes(factory, safe)
    assert len(r) == 1

    cobosafe = CoboSafeAccount.at(r[0][0], safe)
    assert cobosafe.authorizer()
    assert cobosafe.roleManager()
