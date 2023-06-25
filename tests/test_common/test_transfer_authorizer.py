from brownie import ZERO_ADDRESS
from tests.libtest import AuthorizerWrapper, make_tx

NETWORK_NAME = "development"

BUSD = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56"
WBNB = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c"
PANCAKEROUTER = "0x10ED43C718714eb63d5aA57B78B54704E256024E"
MASTERCHEF = "0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652"
ETH = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"

AMOUNT = 100 * 10**18


def test_transfer_authorizer(TransferAuthorizer, owner):
    transferAuthorizer = TransferAuthorizer.deploy(
        owner.address, owner.address, {"from": owner}
    )
    transferAuthorizer.addTokenReceivers([[BUSD, PANCAKEROUTER], [WBNB, MASTERCHEF]])
    assert BUSD in transferAuthorizer.getAllToken.call()
    assert ZERO_ADDRESS not in transferAuthorizer.getAllToken.call()
    assert WBNB in transferAuthorizer.getTokens.call(1, 2)

    assert PANCAKEROUTER in transferAuthorizer.getTokenReceivers.call(BUSD)
    assert MASTERCHEF in transferAuthorizer.getTokenReceivers.call(WBNB)
    assert PANCAKEROUTER not in transferAuthorizer.getTokenReceivers.call(WBNB)

    transferAuthorizer.removeTokenReceivers([[WBNB, MASTERCHEF]])
    assert MASTERCHEF not in transferAuthorizer.getTokenReceivers.call(WBNB)

    wrapper = AuthorizerWrapper(transferAuthorizer)

    assert wrapper.pre_check_func(
        BUSD, "transfer(address,uint256)", [PANCAKEROUTER, AMOUNT]
    )

    assert not wrapper.pre_check_func(
        BUSD, "transfer(address,uint256)", [MASTERCHEF, AMOUNT]
    )

    assert not wrapper.pre_check_func(
        WBNB, "transfer(address,uint256)", [PANCAKEROUTER, AMOUNT]
    )

    transferAuthorizer.addTokenReceivers([[ETH, PANCAKEROUTER]])

    assert wrapper.pre_check_tx(make_tx(to=PANCAKEROUTER, value=1))

    assert not wrapper.pre_check_func(
        WBNB, "approver(address,uint256)", [PANCAKEROUTER, AMOUNT]
    )

    assert not wrapper.pre_check_tx(make_tx(to=MASTERCHEF, value=1))
