from brownie import ZERO_ADDRESS, Wei
from tests.libtest import AuthorizerWrapper

WithdrawQuene = "0x889edC2eDab5f40e902b864aD4d7AdE8E412F9B1"


def test_withdraw_request(LidoWithdrawRequestAuthorizer, owner):
    auth = LidoWithdrawRequestAuthorizer.deploy(owner, owner, {"from": owner})
    authorizer = AuthorizerWrapper(auth)

    # test requestWithdrawal
    assert authorizer.pre_check_func(
        WithdrawQuene,
        "requestWithdrawals(uint256[],address)",
        [[Wei("10 ethers")], ZERO_ADDRESS],
    )
    assert authorizer.pre_check_func(
        WithdrawQuene,
        "requestWithdrawals(uint256[],address)",
        [[Wei("10 ethers")], str(owner)],
    )
    # test requestWithddrawalWstETH
    assert authorizer.pre_check_func(
        WithdrawQuene,
        "requestWithdrawalsWstETH(uint256[],address)",
        [[Wei("10 ethers")], ZERO_ADDRESS],
    )

    assert authorizer.pre_check_func(
        WithdrawQuene,
        "requestWithdrawalsWstETH(uint256[],address)",
        [[Wei("10 ethers")], str(owner)],
    )

    # error test
    bad_address = WithdrawQuene
    assert not authorizer.pre_check_func(
        WithdrawQuene,
        "requestWithdrawals(uint256[],address)",
        [[Wei("10 ethers")], bad_address],
    )

    assert not authorizer.pre_check_func(
        WithdrawQuene,
        "requestWithdrawalsWstETH(uint256[],address)",
        [[Wei("10 ethers")], bad_address],
    )
