// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Enum {
    enum Operation {
        Call,
        DelegateCall
    }
}

interface ISafe {
    function getOwners() external view returns (address[] memory);

    function getThreshold() external view returns (uint256);
}



contract SimpleSafeGuard is Ownable {
    bool public enabled = true;
    address public executor;

    event StatusChanged(bool indexed enabled);
    event ExecutorSet(address indexed executor);

    constructor(address _owner, address _executor) {
        _transferOwnership(_owner);
        executor = _executor;
    }

    function enable() external onlyOwner {
        enabled = true;
        emit StatusChanged(true);
    }

    function disable() external onlyOwner {
        enabled = false;
        emit StatusChanged(false);
    }

    function setExecutor(address _executor) external onlyOwner {
        executor = _executor;
        emit ExecutorSet(_executor);
    }

    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) external {
        if (!enabled) return;
        require(to != msg.sender, "Call self not allowed");
        require(operation == Enum.Operation.Call, "Only call allowed");
        require(
            safeTxGas == 0 &&
                baseGas == 0 &&
                gasPrice == 0 &&
                uint160(gasToken) == 0 &&
                uint160(address(refundReceiver)) == 0,
            "Gas fee sponsorship not allowed"
        );
        require(executor == address(0) || executor == msgSender, "Only executor allowed");
    }

    function checkAfterExecution(bytes32 hash, bool success) external {}

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return
            interfaceId == hex"e6d7a83a" || // type(ITransactionGuard).interfaceId
            interfaceId == hex"01ffc9a7"; // type(IERC165).interfaceId;
    }
}
