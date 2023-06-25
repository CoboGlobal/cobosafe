import eth_abi
from brownie import (
    ZERO_ADDRESS,
    CoboFactory,
    CoboSafeAccount,
    CoboSmartAccount,
    DummyAuthorizer,
    DummyRoleManager,
    FlatRoleManager,
    chain,
    interface,
    network,
    web3,
)
from brownie.exceptions import VirtualMachineError
from hexbytes import HexBytes

from .libutils import (
    DEFAULT_DELEGATE,
    DEFAULT_OWNER,
    abi_encode_with_sig,
    b32,
    make_call,
    make_func_tx,
    make_tx_from_raw_tx,
)

CHAIN_CONFIG = {
    "polygon-main-fork": {
        "safe_implement": "0x3E5c63644E683549055b9Be8653de26E0B4CD36E",
        "gnosis_safe_factory": "0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2",
    },
    "mainnet-fork": {
        "safe_implement": "0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552",
        "gnosis_safe_factory": "0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2",
    },
    "bsc-main-fork": {
        "safe_implement": "0x3E5c63644E683549055b9Be8653de26E0B4CD36E",
        "gnosis_safe_factory": "0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2",
    },
}


class Operation:
    CALL = 0
    DELEGATE_CALL = 1


class GnosisSafeWrapper(object):
    cache = {}

    def __init__(self, safe_address, owner) -> None:
        self.owner = owner
        self.safe = interface.IGnosisSafeProxy(safe_address, owner)

    @classmethod
    def create_single_signature(cls, address):
        return HexBytes(
            eth_abi.encode(["(address,address)"], [(address, address)]) + b"\x01"
        )

    @classmethod
    def auto_create(cls, cur_chain=None, cache=False) -> "GnosisSafeWrapper":
        """
        Create default GnosisSafeProxy by network.
        """

        if cur_chain is None:
            cur_chain = network.show_active()

        if cache and cur_chain in cls.cache:
            return cls.cache[cur_chain]

        assert cur_chain in CHAIN_CONFIG, (
            "GnosisSafeWrapper.auto_create(): chain %s not in CHAIN_CONFIG" % cur_chain
        )
        config = CHAIN_CONFIG[cur_chain]
        impl = config["safe_implement"]
        factory_address = config["gnosis_safe_factory"]
        factory = interface.IGnosisSafeProxyFactory(factory_address, DEFAULT_OWNER)

        data = abi_encode_with_sig(
            "setup(address[],uint256,address,bytes,address,address,uint256,address)",
            [
                [DEFAULT_OWNER],  # owners
                1,  # threshold
                ZERO_ADDRESS,
                b"",
                ZERO_ADDRESS,
                ZERO_ADDRESS,
                0,
                ZERO_ADDRESS,
            ],
        )

        nonce = chain.time()

        safe = factory.createProxyWithNonce.call(impl, data, nonce)

        factory.createProxyWithNonce(impl, data, nonce)

        wrapper = cls(safe, DEFAULT_OWNER)
        if cache:
            cls.cache[cur_chain] = wrapper

        return wrapper

    def exec_transaction(
        self, to, data, value=0, signatures=None, call_type=Operation.CALL
    ):
        if signatures is None:
            signatures = self.create_single_signature(str(self.owner))

        return self.safe.execTransaction(
            to,
            value,
            data,
            call_type,  # 0 for call, 1 for delegatecall
            0,
            0,
            0,
            ZERO_ADDRESS,
            ZERO_ADDRESS,
            signatures,
            {"from": self.owner},
        )

    def exec_transaction_ex(
        self, to, func_sig, args, value=0, signatures=None, call_type=Operation.CALL
    ):
        data = abi_encode_with_sig(func_sig, args)
        return self.exec_transaction(to, data, value, signatures, call_type)

    def enable_module(self, cobo_safe_module):
        self.exec_transaction_ex(
            self.safe.address, "enableModule(address)", [cobo_safe_module]
        )

    def approve_token(self, token, to, amount=None):
        if amount is None:
            amount = 2**256 - 1

        self.exec_transaction_ex(token, "approve(address,uint256)", (to, amount))


class CoboSmartAccountWrapper(object):
    def __init__(self, account) -> None:
        self.account = account

    @property
    def wallet(self):
        return self.account

    @property
    def wallet_address(self):
        return self.account.getAccountAddress()

    @classmethod
    def auto_create(
        cls, owner=None, role_manager=None, auth=None, cur_chain=None, cache=False
    ) -> "CoboSmartAccountWrapper":
        if cur_chain is None:
            cur_chain = network.show_active()

        if cache and cur_chain in cls.cache:
            return cls.cache[cur_chain]

        if owner is None:
            owner = DEFAULT_OWNER

        account = CoboSmartAccount.deploy(owner, {"from": DEFAULT_DELEGATE})
        if role_manager is None:
            role_manager = DummyRoleManager.deploy({"from": DEFAULT_DELEGATE})

        if auth is None:
            auth = DummyAuthorizer.deploy(owner, account, {"from": DEFAULT_DELEGATE})

        wrapper = cls(account)
        wrapper.set_authorizer(auth)
        wrapper.set_role_manager(role_manager)
        wrapper.add_delegate(owner)
        wrapper.add_delegate(DEFAULT_DELEGATE)

        assert wrapper.wallet_address == account.address

        if cache:
            cls.cache[cur_chain] = wrapper

        return wrapper

    def exec_transaction(
        self, to, data=b"", value=0, sender=None, flag=Operation.CALL, use_hint=True
    ):
        if sender is None:
            sender = self.account.owner()
        tx = make_call(to, data, value, flag)
        if use_hint:
            try:
                ret = self.account.execTransaction.call(tx, {"from": sender})

                # NOTE: Update this if CallData/TransactionResult struct changes.
                # CallData.hint = TransactionResult.hint
                tx[4] = ret[2]

            except VirtualMachineError as e:
                # Run without hint.
                print("[-] Get Hint Error", e)
                pass

        return self.account.execTransaction(tx, {"from": sender})

    def exec_transaction_ex(
        self,
        to,
        func_sig,
        args,
        value=0,
        sender=None,
        flag=Operation.CALL,
        use_hint=True,
    ):
        print("Call", func_sig)
        data = abi_encode_with_sig(func_sig, args)
        return self.exec_transaction(to, data, value, sender, flag, use_hint)

    def add_delegate(self, delegate):
        self.account.addDelegate(delegate, {"from": self.account.owner()})

    def set_authorizer(self, auth):
        self.account.setAuthorizer(auth, {"from": self.account.owner()})
        # Update caller.
        auth.setCaller(self.account, {"from": auth.owner()})

    def set_role_manager(self, role_manager):
        self.account.setRoleManager(role_manager, {"from": self.account.owner()})

    def set_flat_role_manager(self, roles=[], delegates=[]):
        assert len(roles) == len(delegates), "roles/delegates pair mismatch"
        owner = self.account.owner()
        role_manager = FlatRoleManager.deploy(owner, {"from": owner})
        if roles:
            role_manager.grantRoles(roles, delegates, {"from": owner})
        self.set_role_manager(role_manager)

    def approve_token(self, token, to, amount=None):
        if amount is None:
            amount = 2**256 - 1

        self.exec_transaction_ex(token, "approve(address,uint256)", (to, amount))


class CoboSafeAccountWrapper(CoboSmartAccountWrapper):
    cache = {}

    @property
    def wallet_address(self):
        # safe.
        return self.account.owner()

    @classmethod
    def auto_create(
        cls,
        safe_wrapper=None,
        role_manager=None,
        auth=None,
        cur_chain=None,
        cache=False,
    ) -> "CoboSafeAccountWrapper":
        if cur_chain is None:
            cur_chain = network.show_active()

        if cache and cur_chain in cls.cache:
            return cls.cache[cur_chain]

        assert cur_chain in CHAIN_CONFIG, (
            "GnosisSafeWrapper.auto_create(): chain %s not in CHAIN_CONFIG" % cur_chain
        )

        if safe_wrapper is None:
            safe_wrapper = GnosisSafeWrapper.auto_create(cur_chain, cache)

        safe_address = safe_wrapper.safe.address

        cobosafe_account = CoboSafeAccount.deploy(
            safe_address, {"from": DEFAULT_DELEGATE}
        )

        if auth is None:
            auth = DummyAuthorizer.deploy(
                safe_address, cobosafe_account, {"from": DEFAULT_DELEGATE}
            )

        if role_manager is None:
            role_manager = DummyRoleManager.deploy({"from": DEFAULT_DELEGATE})

        safe_wrapper.enable_module(cobosafe_account.address)
        wrapper = cls(cobosafe_account)
        wrapper.set_authorizer(auth)
        wrapper.set_role_manager(role_manager)
        wrapper.add_delegate(DEFAULT_OWNER)
        wrapper.add_delegate(DEFAULT_DELEGATE)

        assert wrapper.wallet_address == safe_address

        if cache:
            cls.cache[cur_chain] = wrapper

        return wrapper


class FactoryWrapper(object):
    def __init__(self) -> None:
        self.factory = CoboFactory.deploy(DEFAULT_DELEGATE, {"from": DEFAULT_DELEGATE})

    def add_impl(self, impl_addr):
        self.factory.addImplementation(impl_addr)

    def create(self, name):
        name = b32(name)
        return self.factory.create(name).return_value

    def create2(self, name, salt=b""):
        name = b32(name)
        return self.factory.create2(name, salt).return_value


class AuthorizerWrapper(object):
    FAILED = 0
    SUCCESS = 1

    def __init__(self, auth) -> None:
        self.auth = auth

    @property
    def owner(self):
        return self.auth.owner()

    @property
    def caller(self):
        return self.auth.caller()

    def pause(self, flag=True):
        self.auth.setPaused(flag, {"from": self.owner})

    def set_tag(self, tag):
        self.auth.setTag(tag, {"from": self.owner})

    def set_account(self, account):
        self.auth.setAccount(account, {"from": self.owner})

    def set_caller(self, caller):
        self.auth.setCaller(caller, {"from": self.owner})

    def pre_check_tx(self, tx, full=False):
        r = self.auth.preExecCheck.call(tx, {"from": self.caller})
        if full:
            return r
        else:
            return r[0] == AuthorizerWrapper.SUCCESS

    def post_check_tx(self, tx, result=None, authdata=None, full=False):
        if result is None:
            result = [True, b"", b""]
        if authdata is None:
            authdata = [AuthorizerWrapper.SUCCESS, "", b""]
        r = self.auth.postExecCheck.call(tx, result, authdata, {"from": self.caller})

        if full:
            return r
        else:
            return r[0] == AuthorizerWrapper.SUCCESS

    def pre_check_func(self, to, func, args, value=0, full=False):
        return self.pre_check_tx(make_func_tx(func, args, value, to), full=full)

    def post_check_func(
        self, to, func, args, value=0, result=None, authdata=None, full=False
    ):
        return self.post_check_tx(
            make_func_tx(func, args, value, to), result, authdata, full=full
        )

    def pre_check_raw_tx(self, tx, full=False):
        tx = make_tx_from_raw_tx(tx)
        return self.pre_check_tx(tx, full)

    def pre_check_txid(self, txid, full=False):
        tx = web3.eth.getTransaction(txid)
        return self.pre_check_raw_tx(tx, full)

    def post_check_raw_tx(self, tx, result=None, authdata=None, full=False):
        tx = make_tx_from_raw_tx(tx)
        return self.post_check_tx(tx, result, authdata, full)

    def post_check_txid(self, txid, result=None, authdata=None, full=False):
        tx = web3.eth.getTransaction(txid)
        return self.post_check_raw_tx(tx, result, authdata, full)
