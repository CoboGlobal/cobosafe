from brownie import ZERO_ADDRESS
from tests.libtest import b32

NETWORK_NAME = "development"

TRANSFER_AMOUNT_1 = 1
TRANSFER_AMOUNT_2 = 15000
TRANSFER_AMOUNT_1_2 = 7500


def test_factory(factory_wrapper, CoboSafeAccount, delegate):
    impl = CoboSafeAccount.deploy(ZERO_ADDRESS, {"from": delegate})

    factory_wrapper.add_impl(impl)
    factory_wrapper.add_impl(impl)

    factory = factory_wrapper.factory

    name = b32("CoboSafeAccount")
    name_str = name.decode()

    assert bytes(factory.names(0)) == name
    assert factory.getNameString(0) == name_str
    assert factory.getAllNameStrings() == [name_str]

    assert factory.latestImplementations(name) == impl.address
    assert factory.implementations(name, 0) == impl.address
    assert factory.implementations(name, 1) == impl.address

    assert factory_wrapper.create(name)

    factory.createAndRecord(name)
    factory.createAndRecord(name)
    proxy = factory.createAndRecord(name).return_value

    assert factory.getRecordSize(delegate, name) == 3
    assert factory.getLastRecord(delegate, name) == proxy

    assert factory.getAllRecord(delegate, name) == factory.getRecords(
        delegate, name, 0, 100
    )
