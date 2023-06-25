from brownie import ZERO_ADDRESS

NETWORK_NAME = "bsc-main-fork"


def test_gnosis_safe_wrapper(gnosis_safe_wrapper):
    assert gnosis_safe_wrapper.safe.address != ZERO_ADDRESS


def test_cobo_account_wrapper(wallet_wrapper):
    account = wallet_wrapper.wallet
    assert account.address != ZERO_ADDRESS

    auth = account.authorizer()
    assert auth != ZERO_ADDRESS


def test_cobo_safe_wrapper(cobosafe_wrapper):
    cobosafe = cobosafe_wrapper.account

    assert cobosafe.address != ZERO_ADDRESS

    auth = cobosafe.authorizer()
    assert auth != ZERO_ADDRESS
