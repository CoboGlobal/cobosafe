# Role Manager

`Cobo Safe` 支持 [Role-Based Access Control](https://en.wikipedia.org/wiki/Role-based_access_control) 的权限管理模式。在 Web3 的组织架构中，管理者可将执行特定交易的权限绑定到不同的 `Role` 上。组织中的成员作为 `Delegate` 并不会被直接赋予权限，而是通过所对应的 `Role` 来获取对应的权限。`Cobo Argus` 中也使用同样的组织形式。

`Role Manager` 是 `Cobo Safe` 中用于管理 `Delegate` 与 `Role` 的映射关系。

`Role Manager` 应实现如下接口。
```
interface IRoleManager {
    function getRoles(address delegate) external view returns (bytes32[] memory);

    function hasRole(address delegate, bytes32 role) external view returns (bool);
}
```
其中：
- `getRoles()` 用于获取 `Delegate` 所绑定的 `Role`。每个 `Delegate` 可具有一个或多个 `Role`。
- `hasRole()` 用于检查 `Delegate` 是否被赋予了指定的 `Role`