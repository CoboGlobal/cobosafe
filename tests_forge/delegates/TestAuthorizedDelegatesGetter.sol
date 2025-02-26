// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "./AuthorizedDelegatesGetter.sol";

contract TestAuthorizedDelegatesGetter is Test {
    function testGetDelegates() public {
        vm.selectFork(vm.createFork("base"));

        AuthorizedDelegatesGetter getter = new AuthorizedDelegatesGetter();

        address _cobosafe = 0x6470a43eb33FB8cb921BED0A6c7a91976e58A529;
        address _safe = 0xCF7DC63589B386aC5480221aCEd621E2063AB13D;
        TransactionData memory _transaction = TransactionData({
            from: _safe, // `msg.sender` who performs the transaction a.k.a wallet address.
            delegate: address(0), // Delegate who calls executeTransactions().
            // Same as CallData
            flag: 0, // 0x1 delegate call, 0x0 call.
            to: 0x19cEeAd7105607Cd444F5ad10dd51356436095a1,
            value: 0,
            data: new bytes(0), // calldata
            hint: new bytes(0),
            extra: new bytes(0)
        });

        address[] memory delegates = getter.getAuthorizedDelegates(_cobosafe, _transaction);
        console.log(delegates.length);
        for (uint256 i = 0; i < delegates.length; ++i) {
            console.log(delegates[i]);
        }
    }
}
