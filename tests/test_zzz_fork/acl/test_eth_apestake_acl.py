from brownie import accounts, interface
from tests.libtest import AuthorizerWrapper

# usage:
# 1、export WEB3_INFURA_PROJECT_ID=0aae8358bfe04803b8e75bb4755eaf07
# 2、brownie test tests/test_zzz_fork/acl/test_eth_apestake_acl.py --network mainnet-fork -s

NETWORK_NAME = "mainnet-fork"

APESTAKE_ADDRESS = "0x5954aB967Bc958940b7EB73ee84797Dc8a2AFbb9"

APECOIN_ADDRESS = "0x4d224452801ACEd8B2F0aebE155379bb5D594381"
APECOIN_HOLDER = "0x91951fa186a77788197975ed58980221872a3352"

BAYC_ADDRESS = "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D"
BAYC_HOLDER = "0x8ad272ac86c6c88683d9a60eb8ed57e6c304bb0c"

MAYC_ADDRESS = "0x60E4d786628Fea6478F785A6d7e704777c86a7c6"
MAYC_HOLDER = "0xF22742F06e4F6d68A8d0B49b9F270bB56affAB38"

BAKC_ADDRESS = "0xba30E5F9Bb24caa003E9f2f0497Ad287FDF95623"
BAKC_HOLDER = "0xF22742F06e4F6d68A8d0B49b9F270bB56affAB38"

TOTAL_AMOUNT = 50000 * 10**18
SUCC_AMOUNT = 10 * 10**18


def test_apestake(ApeStakeAuthorizer, owner, delegate):
    convexAuthorizer = ApeStakeAuthorizer.deploy(
        owner.address, owner.address, {"from": owner}
    )

    wrapper = AuthorizerWrapper(convexAuthorizer)

    # BAYC stake
    BAYC_NFT_tokenId = 1429
    bayc_holder = accounts.at(BAYC_HOLDER, force=True)
    bayc = interface.IERC721(BAYC_ADDRESS)
    bayc.setApprovalForAll(owner.address, True, {"from": bayc_holder})
    bayc.transferFrom(
        bayc_holder.address, owner.address, BAYC_NFT_tokenId, {"from": owner.address}
    )

    assert bayc.ownerOf(BAYC_NFT_tokenId) == owner.address

    assert wrapper.pre_check_func(
        APESTAKE_ADDRESS,
        "depositBAYC((uint32,uint224)[])",
        [[[BAYC_NFT_tokenId, SUCC_AMOUNT]]],
    )

    # MAYC stake
    MAYC_NFT_tokenId = 27635
    mayc_holder = accounts.at(MAYC_HOLDER, force=True)
    mayc = interface.IERC721(MAYC_ADDRESS)
    mayc.setApprovalForAll(owner.address, True, {"from": mayc_holder})
    mayc.transferFrom(
        mayc_holder.address, owner.address, MAYC_NFT_tokenId, {"from": owner.address}
    )

    assert mayc.ownerOf(MAYC_NFT_tokenId) == owner.address

    assert wrapper.pre_check_func(
        APESTAKE_ADDRESS,
        "depositMAYC((uint32,uint224)[])",
        [[[MAYC_NFT_tokenId, SUCC_AMOUNT]]],
    )

    # BAKC stake
    BAYC_BAKC_NFT_tokenId = 1471
    MAYC_BAKC_NFT_tokenId = 3641
    bakc_holder = accounts.at(BAKC_HOLDER, force=True)
    bakc = interface.IERC721(BAKC_ADDRESS)
    bakc.setApprovalForAll(owner.address, True, {"from": bakc_holder})
    bakc.transferFrom(
        bakc_holder.address,
        owner.address,
        BAYC_BAKC_NFT_tokenId,
        {"from": owner.address},
    )
    bakc.transferFrom(
        bakc_holder.address,
        owner.address,
        MAYC_BAKC_NFT_tokenId,
        {"from": owner.address},
    )
    assert bakc.ownerOf(BAYC_BAKC_NFT_tokenId) == owner.address
    assert bakc.ownerOf(MAYC_BAKC_NFT_tokenId) == owner.address

    assert wrapper.pre_check_func(
        APESTAKE_ADDRESS,
        "depositBAKC((uint32,uint32,uint184)[],(uint32,uint32,uint184)[])",
        [[], [[MAYC_NFT_tokenId, MAYC_BAKC_NFT_tokenId, SUCC_AMOUNT]]],
    )
    assert wrapper.pre_check_func(
        APESTAKE_ADDRESS,
        "depositBAKC((uint32,uint32,uint184)[],(uint32,uint32,uint184)[])",
        [[[BAYC_NFT_tokenId, BAYC_BAKC_NFT_tokenId, SUCC_AMOUNT]], []],
    )
