# BaseACL

继承 `BaseAuthorizer` 进行交易的访问控制时，需要自行对交易的 `data` 进行 `abi.decode` 解码。为了方便处理这种情况， `Cobo Safe` 框架中继承 `BaseAuthorizer` 实现了 `BaseACL`。`BaseACL` 使用了一些定义同名函数的编码技巧，可以使开发者免除编写繁琐的 ABI 解码代码的烦恼。

大多数访问控制检查都是在交易前进行的，因此 `BaseACL` 也仅实现了 `preExecCheck` 方法，在这里可以对合约调用时的目标合约地址、函数、参数进行定制化的访问控制。

下面是基于 `BaseACL` 实现定制化 `Authorizer` 的流程：
1. 设置 `NAME`, `VERSION` 等变量。
2. 实现 `contracts()` 函数，该函数应返回 `Authorizer` 所控制的目标合约列表。只有交易的目标地址在这个列表中，`Authorizer` 检查才会继续进行，否则会直接拒绝。
3. 实现具体的合约访问控制检查函数。
  1. 检查函数应与被控制函数定义完全一致，但不应包含返回值，不为 `payable`，且应被转化成 `external view` 定义，即函数内部不允许有修改合约状态的操作。
  2. 检查函数被调用时，其各个参数将与合约调用交易发生时的各个参数值一样，因此可以直接对该参数值进行检查。可直接使用 `Solidity` 的 `require()` 语句进行检查，如果检查不通过，则 `Authorizer` 会拒绝交易执行。
  3. 当 `Authorizer` 需要控制多个目标合约时，在合约控制函数内应使用名为`onlyContract` 的 `modifier` 来检查交易的合约地址，避免 `Delegate` 调用到其他的合约的同名方法。

如下是继承 `BaseACL` 实现定制化的 `Authorizer` 的例子。这个 `Authorizer` 允许 `Delegate` 完成 Pancake 协议的 farm 操作，具体权限包括：
- 允许调用 LP Token 的 `approve()` 方法，但目标限制为 `MasterChef` 合约。
- 允许调用 MasterChef 合约的 `deposit()` 方法，且 `pid` 参数限制值为 `3`
- 允许调用 MasterChef 合约的 `withdraw()` 方法，且 `pid` 参数限制值为 `3`


```solidity
// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "../base/BaseACL.sol";

contract SampleFarmACL is BaseACL {
    bytes32 public constant NAME = "SampleFarmACL";
    uint256 public constant VERSION = 1;

    address public constant LP_TOKEN = 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16;
    address public constant MASTER_CHEF = 0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652;

    constructor(address _owner, address _caller) BaseACL(_owner, _caller) {}

    // 设置 Authorizer 可控制的合约列表，对于 to 不在该列表内的交易 Authorizer 会直接拒绝
    function contracts() public view override returns (address[] memory _contracts) {
        _contracts = new address[](2);
        _contracts[0] = LP_TOKEN;
        _contracts[1] = MASTER_CHEF;
    }

    // 检查对 LP Token 的 approve() 方法的调用，要求仅能授权给 MasterChef 合约
    function approve(address spender, uint256 amount) 
        external view 
        onlyContract(LP_TOKEN)
    {
        require(spender == MASTER_CHEF, "approve: Invalid spender");
    }

    // 检查 deposit() 方法的调用，要求仅能操作 3 号池
    function deposit(uint256 _pid, uint256 _amount) 
        external view 
        onlyContract(MASTER_CHEF)
    {
        require(_pid == 3, "deposit: Pool is not allowed");
    }

    // 检查对 withdraw() 方法的调用，要求仅能操作 3 号池
    function withdraw(uint256 _pid, uint256 _amount) 
        external view 
        onlyContract(MASTER_CHEF)
    {
        require(_pid == 3, "withdraw: Pool is not allowed");
    }
}
```