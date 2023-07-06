# Cobo Argus

[`Cobo Argus`](https://argus.cobo.com/) is a smart contract-based on-chain digital asset management solution. Using `Cobo Safe` as its functionality layer, `Cobo Argus` implements role-based access controls to help you improve workflow efficiency and enhance internal risk management. The deployment structure of `Cobo Safe` in `Cobo Argus` is as follows:

![](../argus.png)

In `Cobo Argus`, `Cobo Safe Account` is used to manage the access control policies of the `Safe Wallet`. `Cobo Safe Account` uses `ArgusRootAuthorizer` as its `Root Authorizer`. Users can then configure `Roles` and `Sub-Authorizers` based on their business needs:

* Each `Sub-Authorizer` indicates one type of `Permission`.
* If a `Role` is associated with multiple `Sub-Authorizers`, it indicates that this `Role` is associated with a set of `Permissions`.
* Different types of `Roles` can be combined to form an `Authorization Strategy`. This allows the`Delegate` to complete a set of pre-configured investment operations in a DeFi protocol. `Cobo Argus` has integrated a number of `Authorization Strategies` by default.

## Workflow

**When a `Safe Owner` delegates `Roles` to a `Delegate`, the workflow is as follows:** &#x20;

1. `Safe Owner` creates a `Cobo Safe Account` and enables a `Module` on Safe.
2. `Safe Owner` configures the `Root Authorizer` and `Role Manager`.
3. `Safe Owner` adds the address of the `Delegate` to the whitelist under the `Cobo Safe Account`.
4. `Safe Owner` adds `Sub-Authorizers` and `Roles` to the `Root Authorizer`. &#x20;
5. `Safe Owner` assigns `Roles` to the `Delegate`.&#x20;

**When a `Delegate` executes a transaction, the workflow is as follows:**&#x20;

1. `Delegate` sends a transaction via the  `Cobo Safe Account`.
2. `Cobo Safe Account` validates whether the address of the `Delegate` has been whitelisted. If no, the transaction will be rejected. If yes, the transaction will be sent to the `Root Authorizer`.
3. `Root Authorizer` queries the `Roles` associated with the `Delegate` with the help of a `Role Manager`.&#x20;
4. `Root Authorizer` locates one or multiple `Sub-Authorizers` associated with each `Role`.
5. If the transaction passes validation from any of these `Sub-Authorizers`, it will be approved. Otherwise, the transaction will be rejected.
6. Once the transaction is approved, `Cobo Safe Account` will call `Safe` to initiate the transaction.
7. After the transaction is executed, `Root Authorizer` will validate the transaction via `postExecCheck`.&#x20;
8. The transaction sent by the `Delegate` is completed.
