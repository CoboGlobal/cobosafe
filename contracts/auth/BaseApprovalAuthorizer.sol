// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../base/BaseSimpleAuthorizer.sol";

abstract contract BaseApprovalAuthorizer is BaseSimpleAuthorizer {
    /// @dev The address marker for chain native token.
    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // function approve(address spender, uint256 value)
    bytes4 internal constant APPROVE_SELECTOR = 0x095ea7b3;

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet tokenSet;

    mapping(address => EnumerableSet.AddressSet) tokenToSpenders;

    event TokenAdded(address indexed token);
    event TokenRemoved(address indexed token);

    event TokenSpenderAdded(address indexed token, address indexed spender);
    event TokenSpenderRemoved(address indexed token, address indexed spender);

    struct TokenSpender {
        address token;
        address spender;
    }

    function _addTokenSpender(address token, address spender) internal virtual {
        if (tokenSet.add(token)) {
            emit TokenAdded(token);
        }

        if (tokenToSpenders[token].add(spender)) {
            emit TokenSpenderAdded(token, spender);
        }
    }

    function _removeTokenSpender(address token, address spender) internal virtual {
        if (tokenToSpenders[token].remove(spender)) {
            emit TokenSpenderRemoved(token, spender);
            if (tokenToSpenders[token].length() == 0) {
                if (tokenSet.remove(token)) {
                    emit TokenRemoved(token);
                }
            }
        }
    }

    function _checkTokenSpender(address token, address spender) internal view returns (bool) {
        return tokenToSpenders[token].contains(spender);
    }

    function _preExecCheck(
        TransactionData calldata transaction
    ) internal view virtual override returns (AuthorizerReturnData memory authData) {
        if (
            transaction.data.length >= 68 && // 4 + 32 + 32
            bytes4(transaction.data[0:4]) == APPROVE_SELECTOR &&
            transaction.value == 0
        ) {
            (address spender /*uint256 value*/, ) = abi.decode(transaction.data[4:], (address, uint256));
            address token = transaction.to;
            if (tokenToSpenders[token].contains(spender)) {
                authData.result = AuthResult.SUCCESS;
                return authData;
            }
        }
        authData.result = AuthResult.FAILED;
        authData.message = "approve not allowed";
    }

    /// @notice Add token-receiver pairs.
    function addTokenSpenders(TokenSpender[] calldata tokenSpenders) external virtual onlyOwner {
        for (uint i = 0; i < tokenSpenders.length; i++) {
            address token = tokenSpenders[i].token;
            address spender = tokenSpenders[i].spender;
            _addTokenSpender(token, spender);
        }
    }

    function removeTokenSpenders(TokenSpender[] calldata tokenSpenders) external virtual onlyOwner {
        for (uint i = 0; i < tokenSpenders.length; i++) {
            address token = tokenSpenders[i].token;
            address spender = tokenSpenders[i].spender;
            _removeTokenSpender(token, spender);
        }
    }

    // View functions.

    function getAllToken() external view returns (address[] memory) {
        return tokenSet.values();
    }

    /// @dev View function allow user to specify the range in case we have very big token set
    ///      which can exhaust the gas of block limit.
    function getTokens(uint256 start, uint256 end) external view returns (address[] memory) {
        uint256 size = tokenSet.length();
        if (end > size) end = size;
        require(start < end, "start >= end");
        address[] memory _tokens = new address[](end - start);
        for (uint i = 0; i < end - start; i++) {
            _tokens[i] = tokenSet.at(start + i);
        }
        return _tokens;
    }

    function getTokenSpenders(address token) external view returns (address[] memory) {
        return tokenToSpenders[token].values();
    }

    function checkTokenSpender(address token, address spender) external view returns (bool) {
        return _checkTokenSpender(token, spender);
    }
}
