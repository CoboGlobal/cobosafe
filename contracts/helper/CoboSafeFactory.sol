// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../../interfaces/IVersion.sol";

interface IGnosisSafeProxyFactory {
    function createProxyWithNonce(
        address _singleton,
        bytes memory initializer,
        uint256 saltNonce
    ) external returns (address);
}

interface IGnosisSafe {
    function addOwnerWithThreshold(address owner, uint256 _threshold) external;

    function setup(
        address[] calldata _owners,
        uint256 _threshold,
        address to,
        bytes calldata data,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver
    ) external;

    function removeOwner(address prevOwner, address owner, uint256 _threshold) external;

    function execTransaction(
        address to,
        uint256 value,
        bytes calldata data,
        uint8 operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures
    ) external payable returns (bool success);

    function getOwners() external view returns (address[] memory);

    function getThreshold() external view returns (uint256);

    function getModulesPaginated(address, uint256) external view returns (address[] memory, address);

    function isOwner(address owner) external view returns (bool);
}

interface ICoboArgusFactory {
    function getLatestImplementation(bytes32) external view returns (address);

    function getCreate2Address(address creator, bytes32 name, bytes32 salt) external view returns (address instance);
}

contract GnosisSafeContractOwner {
    // bytes4(keccak256("isValidSignature(bytes,bytes)")
    bytes4 internal constant EIP1271_MAGIC_VALUE = 0x20c13b0b;

    function isValidSignature(bytes memory _data, bytes memory _signature) public view returns (bytes4) {
        return EIP1271_MAGIC_VALUE;
    }

    function constructSignature() internal view returns (bytes memory) {
        bytes1 v = 0x00;
        bytes32 r = bytes32(uint256(uint160(address(this))));
        bytes32 s = bytes32(uint256(65));
        uint256 signatureDataLength = 0;

        return abi.encodePacked(r, s, v, signatureDataLength);
    }

    function execSafeTransaction(
        IGnosisSafe proxy,
        address to,
        uint256 value,
        bytes memory data,
        uint8 operation
    ) internal returns (bool) {
        return proxy.execTransaction(to, value, data, operation, 0, 0, 0, address(0), payable(0), constructSignature());
    }
}

// https://docs.safe.global/advanced/smart-account-supported-networks/v1.3.0
function _getAddressesByChain()
    returns (address gnosisSafeProxyFactory, address coboArgusFactory, address gnosisSafeFallbackHandler)
{
    uint256 chainid = block.chainid;
    if (chainid == 1) {
        // ETH
        gnosisSafeProxyFactory = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
        coboArgusFactory = 0xC0B00000e19D71fA50a9BB1fcaC2eC92fac9549C;
        gnosisSafeFallbackHandler = 0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4;
    } else if (chainid == 10) {
        // OP
        gnosisSafeProxyFactory = 0xC22834581EbC8527d974F8a1c97E1bEA4EF910BC;
        coboArgusFactory = 0xC0B00000e19D71fA50a9BB1fcaC2eC92fac9549C;
        gnosisSafeFallbackHandler = 0x017062a1dE2FE6b99BE3d9d37841FeD19F573804;
    } else if (chainid == 56) {
        // BSC
        gnosisSafeProxyFactory = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
        coboArgusFactory = 0xC0B00000e19D71fA50a9BB1fcaC2eC92fac9549C;
        gnosisSafeFallbackHandler = 0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4;
    } else if (chainid == 137) {
        // Polygon
        gnosisSafeProxyFactory = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
        coboArgusFactory = 0xC0B00000e19D71fA50a9BB1fcaC2eC92fac9549C;
        gnosisSafeFallbackHandler = 0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4;
    } else if (chainid == 43114) {
        // Avalanche
        gnosisSafeProxyFactory = 0xC22834581EbC8527d974F8a1c97E1bEA4EF910BC;
        coboArgusFactory = 0xC0B00000e19D71fA50a9BB1fcaC2eC92fac9549C;
        gnosisSafeFallbackHandler = 0x017062a1dE2FE6b99BE3d9d37841FeD19F573804;
    } else if (chainid == 42161) {
        // Arbitrum
        gnosisSafeProxyFactory = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
        coboArgusFactory = 0xC0B00000e19D71fA50a9BB1fcaC2eC92fac9549C;
        gnosisSafeFallbackHandler = 0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4;
    } else if (chainid == 8453) {
        // Base
        gnosisSafeProxyFactory = 0xC22834581EbC8527d974F8a1c97E1bEA4EF910BC;
        coboArgusFactory = 0x589b92136f97c26CA8BB907a2e3208580422E847;
        gnosisSafeFallbackHandler = 0x017062a1dE2FE6b99BE3d9d37841FeD19F573804;
    } else if (chainid == 5000) {
        // Mantle
        gnosisSafeProxyFactory = 0xC22834581EbC8527d974F8a1c97E1bEA4EF910BC;
        coboArgusFactory = 0x589b92136f97c26CA8BB907a2e3208580422E847;
        gnosisSafeFallbackHandler = 0x017062a1dE2FE6b99BE3d9d37841FeD19F573804;
    } else if (chainid == 100) {
        // Gnosis
        gnosisSafeProxyFactory = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
        coboArgusFactory = 0xC0B00000e19D71fA50a9BB1fcaC2eC92fac9549C;
        gnosisSafeFallbackHandler = 0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4;
    } else if (chainid == 169) {
        // Manta
        gnosisSafeProxyFactory = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
        coboArgusFactory = 0x589b92136f97c26CA8BB907a2e3208580422E847;
        gnosisSafeFallbackHandler = 0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4;
    } else if (chainid == 34443) {
        // Mode
        gnosisSafeProxyFactory = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
        coboArgusFactory = 0x589b92136f97c26CA8BB907a2e3208580422E847;
        gnosisSafeFallbackHandler = 0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4;
    } else if (chainid == 534352) {
        // Scroll
        gnosisSafeProxyFactory = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
        coboArgusFactory = 0xC0B00000e19D71fA50a9BB1fcaC2eC92fac9549C;
        gnosisSafeFallbackHandler = 0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4;
    } else if (chainid == 11155111) {
        // ETH Sepolia
        gnosisSafeProxyFactory = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
        coboArgusFactory = 0x23917b99785Aeb79bB6E621d6b78F616E013e2aA;
        gnosisSafeFallbackHandler = 0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4;
    } else {
        revert("Addresses not set");
    }
}

contract CoboSafeFactory is GnosisSafeContractOwner {
    struct TokenReceiver {
        address token;
        address receiver;
    }

    bytes32 public constant NAME = "CoboSafeFactory";
    uint256 public constant VERSION = 2;

    bytes32 constant COBO_SAFE_ACCOUNT_NAME = "CoboSafeAccount";
    bytes32 constant TRANSFER_AUTHORIZER_NAME = "TransferAuthorizer";
    bytes32 constant COBO_ARGUS_ACCOUNT_HELPER = "ArgusAccountHelper";

    address public immutable gnosisSafeFallbackHandler;
    address public immutable coboArgusFactory;
    address public immutable gnosisSafeProxyFactory;

    constructor() {
        (gnosisSafeProxyFactory, coboArgusFactory, gnosisSafeFallbackHandler) = _getAddressesByChain();
    }

    function createSafe(address singleton, uint256 saltNonce) internal returns (address) {
        address[] memory owners = new address[](1);
        owners[0] = address(this);
        bytes memory data = abi.encodeWithSignature(
            "setup(address[],uint256,address,bytes,address,address,uint256,address)",
            owners,
            1,
            address(0),
            "",
            gnosisSafeFallbackHandler,
            address(0),
            0,
            address(0)
        );
        address proxy = IGnosisSafeProxyFactory(gnosisSafeProxyFactory).createProxyWithNonce(
            singleton,
            data,
            saltNonce
        );

        return proxy;
    }

    function getCoboSafeSalt(IGnosisSafe proxy) internal view returns (bytes32) {
        address coboSafeImpl = ICoboArgusFactory(coboArgusFactory).getLatestImplementation(COBO_SAFE_ACCOUNT_NAME);
        return keccak256(abi.encodePacked(address(proxy), IVersion(coboSafeImpl).VERSION()));
    }

    function calcCreate2Address(IGnosisSafe proxy, bytes32 name, bytes32 salt) internal view returns (address) {
        return ICoboArgusFactory(coboArgusFactory).getCreate2Address(address(proxy), name, salt);
    }

    function initCoboSafeForSafe(IGnosisSafe proxy) internal returns (address) {
        address coboArgusAccountHelper = ICoboArgusFactory(coboArgusFactory).getLatestImplementation(
            COBO_ARGUS_ACCOUNT_HELPER
        );
        // create & init cobo safe
        bytes32 salt = getCoboSafeSalt(proxy);
        bytes memory data = abi.encodeWithSignature("initArgus(address,bytes32)", coboArgusFactory, salt);
        require(execSafeTransaction(proxy, coboArgusAccountHelper, 0, data, 1), "Setup CoboSafe failed");

        // calculate cobo safe address
        address coboSafe = calcCreate2Address(proxy, COBO_SAFE_ACCOUNT_NAME, salt);

        return coboSafe;
    }

    function transferOwnershipAndSetThreshold(IGnosisSafe proxy, address[] memory owners, uint256 threshold) internal {
        require(owners.length > 0, "Owners must not be empty");
        require(threshold > 0 && threshold <= owners.length, "Invalid threshold");
        for (uint256 i = 0; i < owners.length; i++) {
            require(
                execSafeTransaction(
                    proxy,
                    address(proxy),
                    0,
                    abi.encodeWithSignature("addOwnerWithThreshold(address,uint256)", owners[i], 1),
                    0
                ),
                "Add owner failed"
            );
        }
        address prevOwner = getPrevOwner(proxy, address(this));
        require(
            execSafeTransaction(
                proxy,
                address(proxy),
                0,
                abi.encodeWithSignature("removeOwner(address,address,uint256)", prevOwner, address(this), threshold),
                0
            ),
            "Remove owner failed"
        );
    }

    function createSafeAndCoboSafe(
        address singleton,
        uint256 saltNonce,
        address[] memory owners,
        uint256 threshold
    ) public returns (address, address) {
        IGnosisSafe proxy = IGnosisSafe(createSafe(singleton, saltNonce));
        address coboSafe = initCoboSafeForSafe(proxy);
        transferOwnershipAndSetThreshold(proxy, owners, threshold);
        return (address(proxy), coboSafe);
    }

    function getPrevOwner(IGnosisSafe proxy, address owner) internal view returns (address prevOwner) {
        address[] memory owners = proxy.getOwners();
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == owner) {
                if (i == 0) {
                    prevOwner = address(0x1);
                } else {
                    prevOwner = owners[i - 1];
                }
            }
        }
        require(prevOwner != address(0), "Owner not found");
    }
}
