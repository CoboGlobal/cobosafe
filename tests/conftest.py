import pytest
from brownie import network
from brownie.network.account import _PrivateKeyAccount
from brownie.utils import color

from .libtest import (
    CoboSafeAccountWrapper,
    CoboSmartAccountWrapper,
    FactoryWrapper,
    GnosisSafeWrapper,
)

origin_func = _PrivateKeyAccount._await_confirmation


def _hook(*args, **kwargs):
    r = origin_func(*args, **kwargs)
    if r:
        result = ""
        if r.status == 0:
            result += f"{color('bright red')}REVERT{color} "
        else:
            result += f"{color('bright green')}SUCCESS{color} "

        if r.contract_address and r.status:
            result += f"New {color('bright blue')}{r.contract_name}{color} "
            result += color.highlight(f"address: {r.contract_address} ")[:-1]
        else:
            if r.input != "0x" and int(r.input, 16):
                result += f"Function: {color('bright blue')}{r._full_name()}{color} "
            else:
                result += color.highlight(f"To: {r.receiver} Value: {r.value} ")[:-1]

        result += color.highlight(
            f"Block: {r.block_number} Gas Used: "
            f"{r.gas_used} / {r.gas_limit} "
            f"({r.gas_used / r.gas_limit:.1%}) "
        )

        print(result)
        # r.info()
    return r


_PrivateKeyAccount._await_confirmation = _hook


@pytest.fixture
def owner(accounts):
    return accounts[0]


@pytest.fixture
def delegate(accounts):
    return accounts[1]


@pytest.fixture
def receiver(accounts):
    return accounts[2]


@pytest.fixture
def delegate2(accounts):
    return accounts[3]


@pytest.fixture
def cobo_token(CoboToken, owner):
    return CoboToken.deploy(10000e18, {"from": owner})


@pytest.fixture(scope="module", autouse=True)
def auto_switch_chain(request):
    # network.main.CONFIG.networks["avax-main"]["host"] = "https://rpc.ankr.com/avalanche"
    # network.main.CONFIG.networks["polygon-main"]["host"] = "https://rpc.ankr.com/polygon"
    # network.main.CONFIG.networks["mainnet"]["host"] = "https://rpc.ankr.com/eth"

    new_chain = getattr(request.module, "NETWORK_NAME", None)
    current_chain = network.show_active()
    if new_chain and current_chain != new_chain:
        if network.is_connected():
            network.disconnect()
        network.connect(new_chain)
        yield
        # switch back.
        if network.is_connected():
            network.disconnect()
        network.connect(current_chain)
    else:
        yield


@pytest.fixture
def chain_type():
    yield network.show_active()


@pytest.fixture
def gnosis_safe_wrapper():
    yield GnosisSafeWrapper.auto_create()


@pytest.fixture
def cobosafe_wrapper():
    yield CoboSafeAccountWrapper.auto_create()


@pytest.fixture
def cobosmart_wrapper():
    yield CoboSmartAccountWrapper.auto_create()


@pytest.fixture
def wallet_wrapper(cobosmart_wrapper):
    yield cobosmart_wrapper


@pytest.fixture
def RuleSetACLWithLib(delegate, RuleLib, RuleSetACL):
    RuleLib.deploy({"from": delegate})
    # call this before deployment of RuleSetACL
    yield RuleSetACL


@pytest.fixture
def factory_wrapper():
    yield FactoryWrapper()
