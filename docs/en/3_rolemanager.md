# Role Manager

`Cobo Safe` is designed in the [Role-Based Access Control (RBAC)](https://en.wikipedia.org/wiki/Role-based\_access\_control) approach.

The admins of an organization can create a `Role` and assign permissions to the `Role`. Team members, often referred to as `Delegates` in `Cobo Safe`, can only acquire permissions through their delegated roles.

`Role Manager` is a module in `Cobo Safe`. It is used to manage the `Delegate-Role` relationship.

Developer can create their own `Role Managers` by implementing the following interfaces:

```solidity
interface IRoleManager {
    function getRoles(address delegate) external view returns (bytes32[] memory);

    function hasRole(address delegate, bytes32 role) external view returns (bool);
}
```

* `getRoles()` is used to query the `Role` or `Roles` assigned to a `Delegate`
* `hasRole()` is used to check whether a specific `Role` has been assigned to the `Delegate`
