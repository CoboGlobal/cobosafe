// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "../../base/BaseSimpleAuthorizer.sol";
import "./BaseRecorder.sol";

abstract contract BaseRateLimitAuthorizer is BaseSimpleAuthorizer {
    bytes32 public constant override TYPE = AuthType.RATE;

    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address internal constant ANY = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
    uint8 internal constant TR_TYPE = 2;

    address public recorderAuthorizer;

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    EnumerableSet.AddressSet tokenSet;
    mapping(address => EnumerableSet.AddressSet) tokenToAccounts;
    mapping(address => mapping(address => EnumerableSet.UintSet)) tokenAccountPeriods;
    mapping(address => mapping(address => mapping(uint256 => uint256))) tokenAccountAllowance;

    event RecorderSet(address indexed recorder);
    event TokenAccountAllowanceSet(address indexed token, address indexed account, uint256 period, uint256 limit);
    event TokenAccountAllowanceUnset(address indexed token, address indexed account, uint256 period);

    struct TokenAccount {
        address token;
        address account;
    }

    struct AccountAllowance {
        uint256 period;
        uint256 limit;
    }

    struct TokenAccountAllowance {
        address token;
        address account;
        uint256 period;
        uint256 limit;
    }

    struct TokenAccountUnset {
        address token;
        address account;
        uint256 period;
    }

    error InvalidRecorder();
    error InvalidToken();
    error InvalidStartIndex();

    constructor(address _owner, address _caller) BaseSimpleAuthorizer(_owner, _caller) {}

    // Owner functions.

    function setRecorder(address recorder) external onlyOwner {
        if (recorder == address(0)) revert InvalidRecorder();
        recorderAuthorizer = recorder;
        emit RecorderSet(recorder);
    }

    function setTokenAccountAllowance(TokenAccountAllowance[] calldata tokenAccountAllowances) external onlyOwner {
        uint length = tokenAccountAllowances.length;
        for (uint i = 0; i < length; ) {
            address token = tokenAccountAllowances[i].token;
            address account = tokenAccountAllowances[i].account;
            uint256 period = tokenAccountAllowances[i].period;
            uint256 limit = tokenAccountAllowances[i].limit;

            if (token == address(0)) revert InvalidToken();

            tokenAccountAllowance[token][account][period] = limit;
            // period = 0 -> Per Tx
            // period = n -> rate limit / (n Seconds)

            // token -> account -> period -> limit
            //
            // token -> account -> 0 -> 0  : default
            // token -> account -> 0 -> 100 : Per Tx / 100
            // token -> account -> 10 -> 100 : 10 Seconds / 100
            // token -> account -> 20 -> 200 : 20 Seconds / 200

            emit TokenAccountAllowanceSet(token, account, period, limit);

            tokenSet.add(token);
            tokenToAccounts[token].add(account);
            tokenAccountPeriods[token][account].add(period);

            unchecked {
                ++i;
            }
        }
    }

    function unsetTokenAccountAllowance(TokenAccountUnset[] calldata TokenAccountUnsets) external onlyOwner {
        uint length = TokenAccountUnsets.length;
        for (uint i = 0; i < length; ) {
            address token = TokenAccountUnsets[i].token;
            address account = TokenAccountUnsets[i].account;
            uint256 period = TokenAccountUnsets[i].period;

            if (token == address(0)) revert InvalidToken();

            delete tokenAccountAllowance[token][account][period];
            tokenAccountPeriods[token][account].remove(period);

            emit TokenAccountAllowanceUnset(token, account, period);

            if (tokenAccountPeriods[token][account].length() == 0) {
                tokenToAccounts[token].remove(account);
            }

            if (tokenToAccounts[token].length() == 0) {
                tokenSet.remove(token);
            }

            unchecked {
                ++i;
            }
        }
    }

    // View functions.

    function getTokensLength() external view returns (uint256) {
        return tokenSet.length();
    }

    /// @dev View function allow user to specify the range in case we have very big token set
    ///      which can exhaust the gas of block limit.
    function getTokens(uint256 start, uint256 end) external view returns (address[] memory) {
        uint256 size = tokenSet.length();
        if (end > size) end = size;
        if (start >= end) revert InvalidStartIndex();
        address[] memory _tokens = new address[](end - start);
        for (uint i = 0; i < end - start; ) {
            _tokens[i] = tokenSet.at(start + i);
            unchecked {
                ++i;
            }
        }
        return _tokens;
    }

    function getTokenAccountsLength(address token) external view returns (uint256) {
        return tokenToAccounts[token].length();
    }

    function getTokenAccounts(address token, uint256 start, uint256 end) external view returns (address[] memory) {
        uint256 size = tokenToAccounts[token].length();
        if (end > size) end = size;
        if (start >= end) revert InvalidStartIndex();
        address[] memory _accounts = new address[](end - start);
        for (uint i = 0; i < end - start; ) {
            _accounts[i] = tokenToAccounts[token].at((start + i));
            unchecked {
                ++i;
            }
        }
        return _accounts;
    }

    function getTokenAccountPeriodsLength(address token, address account) external view returns (uint256) {
        return tokenAccountPeriods[token][account].length();
    }

    function getTokenAccountPeriods(
        address token,
        address account,
        uint256 start,
        uint256 end
    ) external view returns (uint256[] memory) {
        uint256 size = tokenAccountPeriods[token][account].length();
        if (end > size) end = size;
        if (start >= end) revert InvalidStartIndex();
        uint256[] memory _periods = new uint256[](end - start);
        for (uint i = 0; i < end - start; ) {
            _periods[i] = tokenAccountPeriods[token][account].at((start + i));
            unchecked {
                ++i;
            }
        }
        return _periods;
    }

    function getTokenAccountAllowance(address token, address account, uint256 period) external view returns (uint256) {
        return tokenAccountAllowance[token][account][period];
    }

    // Internal functions.

    function _preExecCheck(
        TransactionData calldata transaction
    ) internal view virtual override returns (AuthorizerReturnData memory authData) {
        (address token, address account, uint256 amount) = _decodeTransactionData(transaction);

        if (
            (token != address(0)) && _preTokenAccountAllowanceCheck(token, account, amount) // only transfer transaction
        ) {
            authData.result = AuthResult.SUCCESS;
            return authData;
        } else {
            authData.result = AuthResult.FAILED;
            authData.message = "check failed";
            return authData;
        }
    }

    function _preTokenAccountAllowanceCheck(
        address token,
        address account,
        uint256 amount
    ) internal view returns (bool) {
        bool preCheckResult;

        TokenAccount[] memory tokenAccounts = new TokenAccount[](TR_TYPE);
        tokenAccounts[0] = TokenAccount({token: token, account: account});
        tokenAccounts[1] = TokenAccount({token: token, account: ANY});

        for (uint256 j = 0; j < TR_TYPE; ) {
            TokenAccount memory tokenAccount = tokenAccounts[j];
            EnumerableSet.UintSet storage _periods = tokenAccountPeriods[tokenAccount.token][tokenAccount.account];
            uint256 _periodLength = _periods.length();

            for (uint256 i = 0; i < _periodLength; ) {
                (bool tokenAccountHasPolicy, bool tokenAccountPolicyCheckPassed) = _accruedTokenAccountAllowanceCheck(
                    tokenAccount.token,
                    tokenAccount.account,
                    _periods.at(i),
                    amount
                );

                if (tokenAccountHasPolicy && !tokenAccountPolicyCheckPassed) {
                    // (true,false)
                    return false;
                }

                if (tokenAccountHasPolicy && tokenAccountPolicyCheckPassed) {
                    // (true,true)
                    preCheckResult = true;
                }

                unchecked {
                    ++i;
                }
            }
            unchecked {
                ++j;
            }
        }
        return preCheckResult;
    }

    /// @dev Check whether the transaction matches the policy or not, and if it does, determine whether it has passed or failed.
    /// @return tokenAccountHasPolicy, means whether the token account has a policy.
    /// @return tokenAccountPolicyCheckPassed, means whether the policy check for token account has passed.
    function _accruedTokenAccountAllowanceCheck(
        address token,
        address account,
        uint256 period,
        uint256 amount
    ) internal view returns (bool, bool) {
        uint256 limit = tokenAccountAllowance[token][account][period];

        if (period == 0 && limit == 0) {
            // default, no policy match
            return (false, false);
        }

        if (period != 0 && limit == 0) {
            // policy match, but check failed
            return (true, false);
        }

        // policy match, default 0
        if (period == 0) {
            // per transaction limit or limit no limit

            if (amount <= limit) {
                return (true, true); // policy match, and check passed
            } else {
                return (true, false); // policy match, but check failed
            }
        } else {
            if (amount > limit) {
                return (true, false); // policy match, but check failed
            }

            (bool checkResult, ) = BaseRecorder(recorderAuthorizer).checkPeriodAmount(
                token,
                account,
                amount,
                limit,
                period
            );
            if (checkResult) {
                return (true, true); // policy match, and check passed
            } else {
                return (true, false); // policy match, but check failed
            }
        }
    }

    function _decodeTransactionData(
        TransactionData calldata transaction
    ) internal pure virtual returns (address token, address account, uint256 amount) {
        (transaction);
        (token, account, amount);
    }
}
