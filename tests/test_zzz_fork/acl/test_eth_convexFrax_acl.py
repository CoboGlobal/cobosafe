from brownie import ZERO_ADDRESS
from tests.libtest import AuthorizerWrapper

NETWORK_NAME = "mainnet-fork"

ConvexStakingWrapperFrax = "0x8a53ee42FB458D4897e15cc7dEa3F75D0F1c3475"
crvFRAX = "0x3175Df0976dFA876431C2E9eE6Bc45b65d3473CC"
crvFRAX_AMOUNT = 500 * 10**18


def test_convexFrax(ConvexFraxAuthorizer, owner, delegate):
    convexFraxAuthorizer = ConvexFraxAuthorizer.deploy(
        owner.address, owner.address, {"from": owner}
    )

    wrapper = AuthorizerWrapper(convexFraxAuthorizer)

    # deposit to ConvexStakingWrapperFrax
    convexFraxAuthorizer.addPoolAddresses([ConvexStakingWrapperFrax])

    assert wrapper.pre_check_func(
        ConvexStakingWrapperFrax,
        "deposit(uint256,address)",
        [crvFRAX_AMOUNT, owner.address],
    )

    assert (
        wrapper.pre_check_func(
            ConvexStakingWrapperFrax,
            "deposit(uint256,address)",
            [crvFRAX_AMOUNT, ZERO_ADDRESS],
        )
    ) is False
