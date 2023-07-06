from brownie import Wei
from tests.libtest import AuthorizerWrapper

lybra = "0x97de57eC338AB5d51557DA3434828C5DbFaDA371"


def test_lybra_mint(LybraMintAuthorizer, owner):
    mint_auth = LybraMintAuthorizer.deploy(owner, owner, {"from": owner})
    auth_wrapper = AuthorizerWrapper(mint_auth)

    def call(to, func_sig, args, value=0):
        auth_wrapper.pre_check_func(to, func_sig, args, value=value)

    # test mint
    call(
        lybra,
        "depositStETHToMint(address,uint256,uint256)",
        [owner.address, Wei("10 ether"), Wei("1 ether")],
    )

    call(
        lybra,
        "depositEtherToMint(address,uint256)",
        [owner.address, Wei("1 ether")],
        value=Wei("10 ethers"),
    )

    call(
        lybra,
        "mint(address,uint256)",
        [owner.address, Wei("1 ether")],
    )


def test_lybra_withdraw(LybraWithdrawAuthorizer, owner):
    mint_auth = LybraWithdrawAuthorizer.deploy(owner, owner, {"from": owner})
    auth_wrapper = AuthorizerWrapper(mint_auth)

    def call(to, func_sig, args, value=0):
        auth_wrapper.pre_check_func(to, func_sig, args, value=value)

    # test mint
    call(
        lybra,
        "withdraw(address,uint256,uint256)",
        [owner.address, Wei("10 ether"), Wei("1 ether")],
    )

    call(
        lybra,
        "burn(address,uint256)",
        [owner.address, Wei("1 ether")],
        value=Wei("10 ethers"),
    )

    call(
        lybra,
        "rigidRedemption(address,uint256)",
        [owner.address, Wei("1 ether")],
    )
