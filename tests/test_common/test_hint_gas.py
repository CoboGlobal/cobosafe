from brownie import ZERO_ADDRESS
from tests.libtest import b32

NETWORK_NAME = "development"

TRANSFER_AMOUNT_1 = 1
TRANSFER_AMOUNT_2 = 15000


def test_account(wallet_wrapper, delegate):
    # CoboSmartAccount + DummyRoleManager + DummyAuthorizer

    account = wallet_wrapper.account
    delegate.transfer(account, "10 ether")

    # 21000
    delegate.transfer(ZERO_ADDRESS, 100)

    # 22392 + 17969
    tx2 = wallet_wrapper.exec_transaction(ZERO_ADDRESS, value=100)
    tx2.call_trace(True)

    """
    Initial call cost  [22392 gas]
    CoboSmartAccount.execTransaction  0:1384  [8039 / 17969 gas]
    ├── BaseAccount.execTransaction  103:179  [1082 gas]
    └── CoboSmartAccount._executeTransactionWithCheck  583:787  [968 / 8848 gas]
        └── CoboSmartAccount._executeTransaction  628:781  [7880 gas]
    """


def test_or(
    wallet_wrapper,
    owner,
    delegate,
    ValuePrePureCheck,
    ArgusRootAuthorizer,
):
    account = wallet_wrapper.account
    delegate.transfer(account, "10 ether")

    root_auth = ArgusRootAuthorizer.deploy(owner, account, account, {"from": owner})

    # Allow all.

    # auth1: 10 <= value <= 1000
    auth1 = ValuePrePureCheck.deploy(owner, root_auth, 1000, 10, {"from": owner})

    # auth2: 500 <= value <= 2000
    auth2 = ValuePrePureCheck.deploy(owner, root_auth, 2000, 500, {"from": owner})

    # auth3: 1 <= value <= 10000
    auth3 = ValuePrePureCheck.deploy(owner, root_auth, 10000, 0, {"from": owner})

    wallet_wrapper.set_authorizer(root_auth)

    role1 = b32("role1")
    role2 = b32("role2")
    role3 = b32("role3")

    root_auth.addAuthorizer(False, role1, auth1)
    root_auth.addAuthorizer(False, role2, auth2)
    root_auth.addAuthorizer(False, role3, auth3)

    def call(value=0, use_hint=True):
        return wallet_wrapper.exec_transaction_ex(
            ZERO_ADDRESS, "foo()", [], value=value, sender=delegate, use_hint=use_hint
        )

    wallet_wrapper.set_flat_role_manager([role3], [delegate])

    tx1 = call(0, False)
    tx2 = call(0, True)

    # 124727 67737
    print(tx1.gas_used, tx2.gas_used)

    assert tx1.gas_used > tx2.gas_used

    wallet_wrapper.set_flat_role_manager(
        [role1, role2, role3], [delegate, delegate, delegate]
    )

    tx1 = call(0, False)
    tx2 = call(0, True)
    # 147803 67737
    print(tx1.gas_used, tx2.gas_used)

    wallet_wrapper.set_flat_role_manager(
        [b32(f"role{i}") for i in range(30)], [delegate] * 30
    )

    tx1 = call(0, False)
    tx2 = call(0, True)  # Move roles check into authorizer.

    # 208832 67737
    print(tx1.gas_used, tx2.gas_used)

    tx2.call_trace()
    """
    Initial call cost  [23288 gas]
    CoboSmartAccount.execTransaction  0:6554  [10163 / 44449 gas]
    ├── BaseAccount.execTransaction  103:179  [1082 gas]
    └── CoboSmartAccount._executeTransactionWithCheck  694:5820  [969 / 33204 gas]
        └── BaseAccount._executeTransactionWithCheck  740:5814  [2659 / 32235 gas]
            ├── ArgusRootAuthorizer.flag  [STATICCALL]  841:911  [1765 gas]
            ├── AuthFlags.isValid  975:991  [54 gas]
            ├── BaseAccount._preExecCheck  1062:5554  [3562 / 26523 gas]
            │   └── ArgusRootAuthorizer.preExecCheck  [CALL]  1494:5148  [7522 / 22961 gas]
            │       ├── BaseAuthorizer.preExecCheck  1598:2564  [1903 / 8594 gas]
            │       │   ├── ArgusRootAuthorizer._preExecCheck  1678:2338  [775 / 2883 gas]
            │       │   │   ├── ArgusRootAuthorizer._preExecCheckWithHint  1779:2074  [666 / 960 gas]
            │       │   │   │   └── ArgusRootAuthorizer._unpackHint  1875:1963  [294 gas]
            │       │   │   ├── ValuePrePureCheck.flag  [STATICCALL]  2111:2174  [940 gas]
            │       │   │   ├── AuthFlags.isValid  2231:2249  [58 gas]
            │       │   │   └── BaseAuthorizer._hasRole  2287:2331  [150 gas]
            │       │   └── BaseAuthorizer._hasRole  2342:2557  [2058 / 3808 gas]
            │       │       └── CoboSmartAccount.roleManager  [STATICCALL]  2420:2492  [1750 gas]
            │       ├── FlatRoleManager.hasRole  [STATICCALL]  2640:2827  [1302 / 2220 gas]
            │       │   └── EnumerableSet.contains  2771:2798  [918 gas]
            │       ├── EnumerableSet.contains  2973:3007  [939 gas]
            │       └── ValuePrePureCheck.preExecCheck  [CALL]  4055:4468  [3686 gas]
            └── CoboSmartAccount._executeTransaction  5570:5742  [1234 gas]
        """
