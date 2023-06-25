from brownie import ZERO_ADDRESS, reverts

NETWORK_NAME = "development"

TRANSFER_AMOUNT_1 = 1
TRANSFER_AMOUNT_2 = 15000
TRANSFER_AMOUNT_1_2 = 7500


def test_proxy_ownable(factory_wrapper, CoboSafeAccount, owner, delegate):
    impl = CoboSafeAccount.deploy(ZERO_ADDRESS, {"from": owner})

    factory_wrapper.add_impl(impl)

    cobosafe = factory_wrapper.create("CoboSafeAccount")
    cobosafe = CoboSafeAccount.at(cobosafe, owner)

    assert cobosafe.owner() == ZERO_ADDRESS
    cobosafe.initialize(owner)

    assert cobosafe.owner() == owner

    with reverts("New Owner is zero"):
        cobosafe.transferOwnership(ZERO_ADDRESS)

    with reverts("Already initialized"):
        cobosafe.initialize(owner)

    cobosafe.transferOwnership(delegate)
    assert cobosafe.owner() == delegate

    cobosafe.setPendingOwner(owner, {"from": delegate})
    cobosafe.acceptOwner()
    assert cobosafe.owner() == owner
    assert cobosafe.pendingOwner() == ZERO_ADDRESS
