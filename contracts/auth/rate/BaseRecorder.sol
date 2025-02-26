// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "../../base/BaseAuthorizer.sol";

abstract contract BaseRecorder is BaseAuthorizer {
    bytes32 public constant override TYPE = AuthType.COMMON;

    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address internal constant ANY = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
    uint256 internal constant MAX = type(uint256).max;
    uint256 internal constant SIZE = 20;

    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet tokenSet;
    mapping(address => EnumerableSet.AddressSet) tokenToAccounts;
    mapping(address => mapping(address => AccountRecord[])) tokenAccountRecords;
    mapping(address => mapping(address => PeriodTotalCache[])) tokenAccountCaches;
    mapping(address => mapping(address => mapping(uint256 => uint256[]))) tokenAccountCacheIndexs;

    struct AccountRecord {
        uint256 amount;
        uint256 timestamp;
    }

    struct PeriodTotalCache {
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 totalAmount;
    }

    error InvalidStartIndex();

    constructor(address _owner, address _caller) BaseAuthorizer(_owner, _caller) {}

    // View functions.

    function flag() external view virtual override returns (uint256) {
        return (AuthFlags.HAS_PRE_CHECK_MASK | AuthFlags.HAS_POST_CHECK_MASK | AuthFlags.HAS_POST_PROC_MASK);
    }

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

    function getTokenAccountRecordsLength(address token, address account) external view returns (uint256) {
        return tokenAccountRecords[token][account].length;
    }

    function getTokenAccountRecords(
        address token,
        address account,
        uint256 start,
        uint256 end
    ) external view returns (AccountRecord[] memory) {
        uint256 size = tokenAccountRecords[token][account].length;
        if (end > size) end = size;
        if (start >= end) revert InvalidStartIndex();
        AccountRecord[] memory _accountRecords = new AccountRecord[](end - start);
        for (uint i = 0; i < end - start; ) {
            _accountRecords[i] = tokenAccountRecords[token][account][(start + i)];
            unchecked {
                ++i;
            }
        }
        return _accountRecords;
    }

    function getTokenAccountCacheIndexs(
        address token,
        address account,
        uint256 index
    ) external view returns (uint256[] memory) {
        return tokenAccountCacheIndexs[token][account][index];
    }

    function getTokenAccountCachesLength(address token, address account) external view returns (uint256) {
        return tokenAccountCaches[token][account].length;
    }

    function getTokenAccountCaches(
        address token,
        address account,
        uint256 start,
        uint256 end
    ) external view returns (PeriodTotalCache[] memory) {
        uint256 size = tokenAccountCaches[token][account].length;
        if (end > size) end = size;
        if (start >= end) revert InvalidStartIndex();
        PeriodTotalCache[] memory _cacheRecords = new PeriodTotalCache[](end - start);
        for (uint i = 0; i < end - start; ) {
            _cacheRecords[i] = tokenAccountCaches[token][account][(start + i)];
            unchecked {
                ++i;
            }
        }
        return _cacheRecords;
    }

    function getPeriodAmount(address token, address account, uint256 period) external view returns (uint256) {
        (, uint256 periodAmount) = checkPeriodAmount(token, account, uint256(0), MAX, period);
        return periodAmount;
    }

    function checkPeriodAmount(
        address token,
        address account,
        uint256 amount,
        uint256 limit,
        uint256 period
    ) public view returns (bool, uint256) {
        uint256 periodAmount = 0;
        uint256 timestamp = uint256(block.timestamp);

        if (token == ANY) {
            return (false, periodAmount);
        }

        if (account == ANY) {
            EnumerableSet.AddressSet storage _accounts = tokenToAccounts[token];
            uint length = _accounts.length();

            for (uint i = 0; i < length; ) {
                (bool _status, uint256 _periodAmount) = _checkTokenAccountPeriodAmount(
                    token,
                    _accounts.at(i),
                    amount,
                    limit,
                    period,
                    timestamp
                );
                if (!_status) {
                    return (false, periodAmount);
                }
                if (periodAmount > MAX - _periodAmount) {
                    //  uint256 overflow
                    return (false, MAX);
                }
                periodAmount += _periodAmount;
                if (amount + periodAmount > limit) {
                    return (false, periodAmount);
                }
                unchecked {
                    ++i;
                }
            }
            return (true, periodAmount);
        }

        return _checkTokenAccountPeriodAmount(token, account, amount, limit, period, timestamp);
    }

    // Internal functions.

    function _preExecCheck(
        TransactionData calldata transaction
    ) internal view virtual override returns (AuthorizerReturnData memory authData) {
        (transaction);
        authData.result = AuthResult.FAILED;
        authData.message = Errors.METHOD_NOT_ALLOW;
        return authData;
    }

    function _postExecCheck(
        TransactionData calldata transaction,
        TransactionResult calldata callResult,
        AuthorizerReturnData calldata preData
    ) internal virtual override returns (AuthorizerReturnData memory authData) {
        (transaction, callResult, preData);
        authData.result = AuthResult.FAILED;
        authData.message = Errors.METHOD_NOT_ALLOW;
        return authData;
    }

    function _postExecProcess(
        TransactionData calldata transaction,
        TransactionResult calldata callResult
    ) internal virtual override {
        if (callResult.success == true) {
            (address token, address account, uint256 amount) = _decodeTransactionData(transaction);

            if (token != address(0)) {
                uint256 timestamp = uint256(block.timestamp);
                tokenAccountRecords[token][account].push(AccountRecord({amount: amount, timestamp: timestamp}));

                _updatePeriodCache(token, account, amount, timestamp);
                tokenSet.add(token);
                tokenToAccounts[token].add(account);
            }
        }
    }

    function _checkTokenAccountPeriodAmount(
        address token,
        address account,
        uint256 amount,
        uint256 limit,
        uint256 period,
        uint256 timestamp
    ) internal view returns (bool, uint256) {
        uint256 periodAmount = 0;

        PeriodTotalCache[] storage periodTotalCaches = tokenAccountCaches[token][account];
        uint256 cachesLength = periodTotalCaches.length;
        uint256 cacheIndex = cachesLength == 0 ? 0 : cachesLength - 1;
        AccountRecord[] storage accountRecords = tokenAccountRecords[token][account];
        uint256 recordsLength = accountRecords.length;
        uint256 recordIndex = recordsLength == 0 ? 0 : recordsLength - 1;

        if (recordsLength == 0) {
            return ((amount <= limit), periodAmount);
        } else if (timestamp - accountRecords[recordIndex].timestamp > period) {
            return ((amount <= limit), periodAmount);
        } else {
            for (uint i = cacheIndex; i >= 0; ) {
                if (timestamp - periodTotalCaches[i].endTimestamp > period) {
                    // cache out period
                    return ((amount + periodAmount <= limit), periodAmount);
                }

                if (timestamp - periodTotalCaches[i].startTimestamp <= period) {
                    // cache in period
                    if (periodAmount > MAX - periodTotalCaches[i].totalAmount) {
                        //  uint256 overflow
                        return (false, periodAmount);
                    }
                    periodAmount += periodTotalCaches[i].totalAmount;
                } else if (
                    (timestamp - periodTotalCaches[i].startTimestamp > period) &&
                    (timestamp - periodTotalCaches[i].endTimestamp <= period)
                ) {
                    uint256[] storage cacheIndexs = tokenAccountCacheIndexs[token][account][i];
                    uint256 cacheIndexsLength = cacheIndexs.length;
                    uint256 cacheIndexsIndex = cacheIndexsLength == 0 ? 0 : cacheIndexsLength - 1;

                    for (uint j = cacheIndexsIndex; j >= 0; ) {
                        if (timestamp - accountRecords[j].timestamp > period) {
                            return ((amount + periodAmount <= limit), periodAmount);
                        }
                        if (periodAmount > MAX - accountRecords[j].amount) {
                            //  uint256 overflow
                            return (false, periodAmount);
                        }
                        periodAmount += accountRecords[j].amount;

                        if (amount + periodAmount > limit) {
                            return (false, periodAmount);
                        }

                        if (j == 0) {
                            break;
                        }
                        unchecked {
                            --j;
                        }
                    }
                }

                if (amount + periodAmount > limit) {
                    return (false, periodAmount);
                }

                if (i == 0) {
                    break;
                }

                unchecked {
                    --i;
                }
            }

            return (true, periodAmount);
        }
    }

    function _updatePeriodCache(address token, address account, uint256 amount, uint256 timestamp) internal {
        PeriodTotalCache[] storage periodTotalCaches = tokenAccountCaches[token][account];
        uint256 cachesLength = periodTotalCaches.length;
        uint256 cacheIndex = cachesLength == 0 ? 0 : cachesLength - 1;
        uint256 recordsLength = tokenAccountRecords[token][account].length; // pushed record before
        uint256 recordIndex = recordsLength == 0 ? 0 : recordsLength - 1;

        if (cachesLength == 0) {
            periodTotalCaches.push(
                PeriodTotalCache({startTimestamp: timestamp, endTimestamp: timestamp, totalAmount: amount})
            );
            tokenAccountCacheIndexs[token][account][cachesLength].push(recordIndex);
        } else {
            uint cacheIndexsLength = tokenAccountCacheIndexs[token][account][cacheIndex].length;
            if (cacheIndexsLength < SIZE) {
                periodTotalCaches[cacheIndex] = PeriodTotalCache({
                    startTimestamp: periodTotalCaches[cacheIndex].startTimestamp,
                    endTimestamp: timestamp,
                    totalAmount: amount > MAX - periodTotalCaches[cacheIndex].totalAmount
                        ? MAX
                        : periodTotalCaches[cacheIndex].totalAmount + amount //  uint256 overflow
                });
                tokenAccountCacheIndexs[token][account][cacheIndex].push(recordIndex);
            } else {
                periodTotalCaches.push(
                    PeriodTotalCache({startTimestamp: timestamp, endTimestamp: timestamp, totalAmount: amount})
                );
                tokenAccountCacheIndexs[token][account][cachesLength].push(recordIndex);
            }
        }
    }

    function _decodeTransactionData(
        TransactionData calldata transaction
    ) internal pure virtual returns (address token, address account, uint256 amount);
}
