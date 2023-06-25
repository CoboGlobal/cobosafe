from brownie import ZERO_ADDRESS
from tests.libtest import AuthorizerWrapper

# usage:
# 1、export WEB3_INFURA_PROJECT_ID=0aae8358bfe04803b8e75bb4755eaf07
# 2、brownie test tests/test_zzz_fork/acl/test_eth_convex_acl.py --network mainnet-fork -s


NETWORK_NAME = "mainnet-fork"

BOOSTER = "0xF403C135812408BFbE8713b5A23a04b3D48AAE31"
REWARD = "0xbD5445402B0a287cbC77cb67B2a52e2FC635dce4"
frxETHCRV = "0xf43211935C781D5ca1a41d2041F397B8A7366C7A"
frxETHCRV_HOLDER = "0x2932a86df44Fe8D2A706d8e9c5d51c24883423F5"
frxETHCRV_AMOUNT = 50 * 10**18
pid = 127


def test_convex(ConvexAuthorizer, owner, delegate):
    convexAuthorizer = ConvexAuthorizer.deploy(
        owner.address, owner.address, {"from": owner}
    )

    wrapper = AuthorizerWrapper(convexAuthorizer)

    # deposit to ConvexStakingWrapperFrax
    convexAuthorizer.addPoolIds([pid])
    convexAuthorizer.setBooster(BOOSTER)
    convexAuthorizer.setRewardPool(REWARD)

    assert wrapper.pre_check_func(
        BOOSTER, "deposit(uint256,uint256,bool)", [pid, frxETHCRV_AMOUNT, True]
    )

    assert (
        wrapper.pre_check_func(
            BOOSTER, "deposit(uint256,uint256,bool)", [128, frxETHCRV_AMOUNT, True]
        )
    ) is False

    assert wrapper.pre_check_func(BOOSTER, "depositAll(uint256,bool)", [pid, True])

    assert (
        wrapper.pre_check_func(BOOSTER, "depositAll(uint256,bool)", [128, True])
    ) is False

    assert wrapper.pre_check_func(
        REWARD, "getReward(address,bool)", [owner.address, True]
    )

    assert (
        wrapper.pre_check_func(REWARD, "getReward(address,bool)", [ZERO_ADDRESS, True])
    ) is False
