from brownie import reverts

NETWORK_NAME = "development"


def test_console(ConsoleTest, owner):
    c = ConsoleTest.deploy({"from": owner})

    c.logBool()
    c.logInt()
    c.logUint()
    c.logBytes32()
    c.logBytes()
    c.logAddress()
    c.logString()

    with reverts("true"):
        c.errorBool()
    with reverts("-1234"):
        c.errorInt()
    with reverts("1234"):
        c.errorUint()
    with reverts("true"):
        c.errorBool()
    with reverts("0x3132333435363738000000000000000000000000000000000000000000000000"):
        c.errorBytes32()
    with reverts("12345678"):
        c.errorBytes()
    with reverts("0x10ed43c718714eb63d5aa57b78b54704e256024e"):
        c.errorAddress()
    with reverts("this is a string"):
        c.errorString()
