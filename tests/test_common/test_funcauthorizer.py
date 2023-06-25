from brownie import reverts

NETWORK_NAME = "development"
TRANSFER_AMOUNT_1 = 1
TRANSFER_AMOUNT_2 = 15000


def test_funcauthorizer(wallet_wrapper, FuncAuthorizer, owner, delegate, cobo_token):
    def delegate_transfer(amount, use_hint=True):
        return wallet_wrapper.exec_transaction_ex(
            cobo_token.address,
            "transfer(address,uint256)",
            [delegate.address, amount],
            sender=delegate,
            use_hint=use_hint,
        )

    account = wallet_wrapper.wallet

    token = cobo_token
    token.transfer(account.address, TRANSFER_AMOUNT_2 * 10)

    func_acl = FuncAuthorizer.deploy(owner, owner, {"from": delegate})
    wallet_wrapper.set_authorizer(func_acl)

    tx = func_acl.addContractFuncs(
        cobo_token, ["transfer(address,uint256)"], {"from": owner}
    )
    print(tx.events)
    delegate_transfer(TRANSFER_AMOUNT_1)

    tx = func_acl.removeContractFuncs(
        cobo_token, ["transfer(address,uint256)"], {"from": owner}
    )
    print(tx.events)
    with reverts("function not allowed"):
        delegate_transfer(TRANSFER_AMOUNT_1)

    tx = func_acl.addContractFuncsSig(
        cobo_token, [bytes.fromhex("a9059cbb")], {"from": owner}
    )
    print(tx.events)
    delegate_transfer(TRANSFER_AMOUNT_1)

    tx = func_acl.removeContractFuncsSig(
        cobo_token, [bytes.fromhex("a9059cbb")], {"from": owner}
    )
    print(tx.events)
    with reverts("function not allowed"):
        delegate_transfer(TRANSFER_AMOUNT_1)
