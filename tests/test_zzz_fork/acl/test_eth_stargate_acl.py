import brownie
from brownie import Wei, accounts, chain, interface
from tests.libtest import b32

NETWORK_NAME = "mainnet-fork"

ROUTER = "0x8731d54E9D02c286767d56ac03e8037C07e01e98"
uniswap = "0xf164fC0Ec4E93095b804a4795bBe1e041497b92a"
WETH = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
USDT = "0xdac17f958d2ee523a2206206994597c13d831ec7"
STARGATE_USDT_POOL_ID = "0x38ea452219524bb87e18de1c24d3bb59510bd783"
PID = 2  # USDT PID
LP_STAKING = "0xb0d502e938ed5f4df2e681fe6e419ff29631d62b"
FACTORY = "0x06D538690AF257Da524f25D0CD52fD85b1c2173E"


def test_stargate_deposit_role(
    wallet_wrapper,
    ArgusRootAuthorizer,
    StargateDepositAuthorizer,
    StargateWithdrawAuthorizer,
    StargateClaimAuthorizer,
    owner,
    delegate,
):
    account = wallet_wrapper.account  # cobo smart account
    deposit_role = b32("stargate-deposit")
    withdraw_role = b32("stargate-withdraw")
    claim_role = b32("stargate-claim")
    claim_delegate = accounts[2]
    withdraw_delegate = accounts[3]

    root_auth = ArgusRootAuthorizer.deploy(owner, account, account, {"from": owner})
    deposit_auth = StargateDepositAuthorizer.deploy(owner, root_auth, {"from": owner})
    wallet_wrapper.add_delegate(claim_delegate)
    wallet_wrapper.add_delegate(withdraw_delegate)
    wallet_wrapper.set_authorizer(root_auth)
    wallet_wrapper.set_flat_role_manager(
        [deposit_role, withdraw_role, claim_role],
        [delegate, withdraw_delegate, claim_delegate],
    )

    # Deposit auth
    deposit_auth.addPoolAddresses([STARGATE_USDT_POOL_ID], {"from": owner})
    deposit_auth.addPoolIds([1], {"from": owner})
    root_auth.addAuthorizer(False, deposit_role, deposit_auth)

    # withdraw auth
    withdraw_auth = StargateWithdrawAuthorizer.deploy(owner, root_auth, {"from": owner})
    withdraw_auth.addPoolIds([1], {"from": owner})
    withdraw_auth.addPoolAddresses([STARGATE_USDT_POOL_ID], {"from": owner})
    root_auth.addAuthorizer(False, withdraw_role, withdraw_auth)

    # claim auth
    claim_auth = StargateClaimAuthorizer.deploy(owner, root_auth, {"from": owner})
    claim_auth.addPoolIds([1], {"from": owner})
    root_auth.addAuthorizer(False, claim_role, claim_auth)

    # approve token
    wallet_wrapper.approve_token(USDT, ROUTER)
    wallet_wrapper.approve_token(STARGATE_USDT_POOL_ID, LP_STAKING)

    def call(to, func_sig, data_lst, value=0, use_hint=True, sender=delegate):
        tx = wallet_wrapper.exec_transaction_ex(
            to, func_sig, data_lst, value=value, sender=sender, use_hint=use_hint
        )
        return tx

    # fund prepare
    interface.IUniswapV2Router01(uniswap).swapExactETHForTokens(
        0,
        [WETH, USDT],
        account,
        chain.time() * 2,
        {"from": owner, "amount": Wei("30 ether")},
    )

    # test addliquidity
    usdt_balance = interface.IERC20(USDT).balanceOf.call(account)

    # gas: 163163
    call(
        ROUTER,
        "addLiquidity(uint256,uint256,address)",
        [PID, usdt_balance, str(account)],
    )

    lp_amount = interface.IERC20(STARGATE_USDT_POOL_ID).balanceOf.call(account)
    assert lp_amount > 0

    # test deposit
    # gas: 159568
    call(LP_STAKING, "deposit(uint256,uint256)", [1, lp_amount])

    # test withdraw
    # gas: 197817
    call(
        LP_STAKING,
        "withdraw(uint256,uint256)",
        [1, lp_amount // 2],
        sender=withdraw_delegate,
    )
    lp_amount_withdraw = interface.IERC20(STARGATE_USDT_POOL_ID).balanceOf.call(account)

    # test removeLiquidity
    # gas: 156788
    call(
        ROUTER,
        "instantRedeemLocal(uint16,uint256,address)",
        [2, lp_amount_withdraw, str(account)],
        sender=withdraw_delegate,
    )

    # test claim
    # gas: 151723
    call(LP_STAKING, "deposit(uint256,uint256)", [1, 0], sender=claim_delegate)

    # error test
    wrong_pid = 3
    wrong_receiver = str(delegate)
    wrong_claim_amount = 100
    correct_farming_pid = 1
    correct_pool_pid = 2
    correct_receiver = str(account)

    with brownie.reverts("E48"):
        call(
            ROUTER,
            "addliquidity(uint256,uint256,address)",
            [wrong_pid, 0, correct_receiver],  # wrong pid
        )

    with brownie.reverts("E48"):
        call(
            ROUTER,
            "addliquidity(uint256,uint256,address)",
            [correct_pool_pid, 0, wrong_receiver],  # wrong receiver
        )

    with brownie.reverts("E48"):
        call(LP_STAKING, "withdraw(uint256,uint256)", [wrong_pid, 0])  # wrong pid
    with brownie.reverts("E48"):
        call(LP_STAKING, "deposit(uint256,uint256)", [wrong_pid, 0])

    with brownie.reverts("E48"):
        call(
            ROUTER,
            "instantRedeemLocal(uint16,uint256,address)",
            [wrong_pid, 0, correct_receiver],
        )

    with brownie.reverts("E48"):
        call(
            ROUTER,
            "instantRedeemLocal(uint16,uint256,address)",
            [correct_pool_pid, 0, wrong_receiver],
        )
    with brownie.reverts("E48"):
        call(LP_STAKING, "deposit(uint256,uint256)", [wrong_pid, 0])

    with brownie.reverts("E48"):
        call(
            LP_STAKING,
            "deposit(uint256,uint256)",
            [correct_farming_pid, wrong_claim_amount],
            sender=claim_delegate,
        )
