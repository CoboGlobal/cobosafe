// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../auth/FarmingBaseACL.sol";

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract ApeStakeAuthorizer is FarmingBaseACL {
    bytes32 public constant NAME = "ApeStakeAuthorizer";
    uint256 public constant VERSION = 1;

    address public constant APE_STAKE = address(0x5954aB967Bc958940b7EB73ee84797Dc8a2AFbb9);
    address public constant BAYC = address(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D);
    address public constant MAYC = address(0x60E4d786628Fea6478F785A6d7e704777c86a7c6);
    address public constant BAKC = address(0xba30E5F9Bb24caa003E9f2f0497Ad287FDF95623);

    uint256 constant APECOIN_POOL_ID = 0;
    uint256 constant BAYC_POOL_ID = 1;
    uint256 constant MAYC_POOL_ID = 2;
    uint256 constant BAKC_POOL_ID = 3;

    struct SingleNft {
        uint32 tokenId;
        uint224 amount;
    }

    struct PairNftDepositWithAmount {
        uint32 mainTokenId;
        uint32 bakcTokenId;
        uint184 amount;
    }

    struct PairNft {
        uint128 mainTokenId;
        uint128 bakcTokenId;
    }

    constructor(address _owner, address _caller) FarmingBaseACL(_owner, _caller) {}

    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](1);
        _contracts[0] = APE_STAKE;
    }

    // Checking functions.

    // ApeCoin staking

    // BAYC staking
    function depositBAYC(SingleNft[] calldata _nfts) external view {
        uint256 tokenId;
        uint256 length = _nfts.length;
        for (uint256 i; i < length; ) {
            tokenId = _nfts[i].tokenId;
            _checkRecipient(IERC721(BAYC).ownerOf(tokenId));
            unchecked {
                ++i;
            }
        }
    }

    // MAYC staking
    function depositMAYC(SingleNft[] calldata _nfts) external view {
        uint256 tokenId;
        uint256 length = _nfts.length;
        for (uint256 i; i < length; ) {
            tokenId = _nfts[i].tokenId;
            _checkRecipient(IERC721(MAYC).ownerOf(tokenId));
            unchecked {
                ++i;
            }
        }
    }

    // BAKC staking
    function depositBAKC(
        PairNftDepositWithAmount[] calldata _baycPairs,
        PairNftDepositWithAmount[] calldata _maycPairs
    ) external view {
        PairNftDepositWithAmount memory _baycPair;
        PairNftDepositWithAmount memory _maycPair;
        uint256 _baycLength = _baycPairs.length;
        uint256 _maycLength = _maycPairs.length;

        for (uint256 i; i < _baycLength; ) {
            _baycPair = _baycPairs[i];
            _checkRecipient(IERC721(BAYC).ownerOf(_baycPair.mainTokenId));
            _checkRecipient(IERC721(BAKC).ownerOf(_baycPair.bakcTokenId));
            unchecked {
                ++i;
            }
        }

        for (uint256 i; i < _maycLength; ) {
            _maycPair = _maycPairs[i];
            _checkRecipient(IERC721(MAYC).ownerOf(_maycPair.mainTokenId));
            _checkRecipient(IERC721(BAKC).ownerOf(_maycPair.bakcTokenId));
            unchecked {
                ++i;
            }
        }
    }
}
