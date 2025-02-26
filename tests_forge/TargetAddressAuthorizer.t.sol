// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "./BaseTest.sol";
import {TargetAddressAuthorizer} from "../contracts/auth/TargetAddressAuthorizer.sol";

contract TargetAddressAuthorizerTest is BaseTest {
    TargetAddressAuthorizer t;

    address constant TO1 = address(1);
    address constant TO2 = address(2);
    bytes DATA = "data";

    function setUp() public override {
        t = new TargetAddressAuthorizer(owner, owner);
    }

    function test_TargetAddressAuthorizer() public {
        assertFalse(checkPerm(address(t), TO1, 0, DATA));

        address[] memory _addresses = new address[](1);
        _addresses[0] = TO1;
        t.addTargetAddresses(_addresses);

        assertTrue(t.isTargetAddressAllowed(TO1));
        assertFalse(t.isTargetAddressAllowed(TO2));

        assertTrue(checkPerm(address(t), TO1, 0, DATA));
        assertTrue(checkPerm(address(t), TO1, 1, DATA));
        assertTrue(checkPerm(address(t), TO1, 1, ""));

        assertFalse(checkPerm(address(t), TO2, 0, DATA));

        _addresses = t.getTargetAddresses();
        assertEq(_addresses.length, 1);
        assertEq(_addresses[0], TO1);

        _addresses = t.getTargetAddresses(0, 10000);
        assertEq(_addresses.length, 1);
        assertEq(_addresses[0], TO1);

        t.removeTargetAddresses(_addresses);
        assertFalse(checkPerm(address(t), TO1, 1, ""));
    }
}
