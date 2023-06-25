from brownie import ZERO_ADDRESS, reverts
from tests.libtest import auto_reset, b32


def get_counter(auth):
    return [
        auth.preCheckCounter(),
        auth.postCheckCounter(),
        auth.preProcessCounter(),
        auth.postProcessCounter(),
    ]


def test_basic(DummyCounterAuthorizer, ArgusRootAuthorizer, owner):
    root_auth = ArgusRootAuthorizer.deploy(owner, owner, owner, {"from": owner})

    dummy = DummyCounterAuthorizer.deploy(owner, root_auth, {"from": owner})
    role = b32("dummy")
    root_auth.addAuthorizer(False, role, dummy)

    assert root_auth.authorizerSize(False, role) == 1
    assert root_auth.hasAuthorizer(False, role, dummy) is True
    assert root_auth.getAuthorizer(False, role, 0) == dummy.address
    assert root_auth.getAuthorizers(False, role, 0, 100) == (dummy.address,)
    assert root_auth.getAllAuthorizers(False, role) == (dummy.address,)


def test_or(
    wallet_wrapper,
    owner,
    delegate,
    DummyCounterAuthorizer,
    ValuePreGT10PostGT1000,
    ValuePreGT1000PostGT10,
    ArgusRootAuthorizer,
):
    account = wallet_wrapper.account
    delegate.transfer(account, "10 ether")

    root_auth = ArgusRootAuthorizer.deploy(owner, account, account, {"from": owner})

    # Allow all.
    dummy = DummyCounterAuthorizer.deploy(owner, root_auth, {"from": owner})

    # Allow when pre value > 10, post value > 1000
    auth1 = ValuePreGT10PostGT1000.deploy(owner, root_auth, {"from": owner})

    # Allow when pre value > 1000, post value > 10
    auth2 = ValuePreGT1000PostGT10.deploy(owner, root_auth, {"from": owner})

    wallet_wrapper.set_authorizer(root_auth)

    def call(value=0, use_hint=True):
        return wallet_wrapper.exec_transaction_ex(
            ZERO_ADDRESS, "foo()", [], value=value, sender=delegate, use_hint=use_hint
        )

    with reverts("E45"):
        # Invalid authorizer flag for root auth as no sub auths added.
        call()

    role1 = b32("role1")
    role2 = b32("role2")

    root_auth.addAuthorizer(False, role1, auth1)
    root_auth.addAuthorizer(False, role2, auth2)
    root_auth.addAuthorizer(False, role2, dummy)

    wallet_wrapper.set_flat_role_manager([role1, role2], [delegate, delegate])

    # Pre: auth1 fail, auth2 fail, dummy pass
    # Post: dummy pass
    with auto_reset:
        call(0, False)
        assert get_counter(auth1) == [1, 0, 1, 1]
        assert get_counter(auth2) == [1, 0, 1, 1]
        assert get_counter(dummy) == [1, 1, 1, 1]

    with auto_reset:
        call(0, True)
        assert get_counter(auth1) == [0, 0, 1, 1]
        assert get_counter(auth2) == [0, 0, 1, 1]
        assert get_counter(dummy) == [1, 1, 1, 1]

    with auto_reset:
        assert call(0, False).gas_used > call(0, True).gas_used

    # Pre: auth1 pass, auth2 fail, dummy pass
    # Post: auth1 fail, dummy pass
    with auto_reset:
        call(100, False)
        assert get_counter(auth1) == [1, 1, 1, 1]
        assert get_counter(auth2) == [1, 0, 1, 1]
        assert get_counter(dummy) == [1, 1, 1, 1]

    with auto_reset:
        call(100, True)
        assert get_counter(auth1) == [0, 0, 1, 1]
        assert get_counter(auth2) == [0, 0, 1, 1]
        assert get_counter(dummy) == [1, 1, 1, 1]

    # Pre: auth1 pass, auth2 pass, dummy pass
    # Post: auth1 pass
    with auto_reset:
        call(10000, False)
        assert get_counter(auth1) == [1, 1, 1, 1]
        assert get_counter(auth2) == [1, 0, 1, 1]
        assert get_counter(dummy) == [1, 0, 1, 1]

    with auto_reset:
        call(10000, True)
        assert get_counter(auth1) == [1, 1, 1, 1]
        assert get_counter(auth2) == [0, 0, 1, 1]
        assert get_counter(dummy) == [0, 0, 1, 1]
