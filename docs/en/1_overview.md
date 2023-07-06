# Overview

`Cobo Safe` is an open-source access control framework for smart contract wallets. Developed by Cobo, this framework allows the `Owner` of a smart contract wallet to delegate certain operations (e.g., transferring tokens, interacting with specific smart contracts) to the `Delegate`. The `Delegate` can then perform authorized wallet operations on behalf of the `Owner`.

The `Cobo Safe` framework includes the following components:

* **Cobo Account:** The wrapper of a smart contract wallet in the `Cobo Safe` framework.
* **Owner:** A privileged user who owns the smart contract wallet. The `Owner` can delegate `Permissions` to other users (i.e., `Delegates`) in a `Cobo Safe` framework.
* **Delegate:** A user of least privilege in a `Cobo Safe` framework. The `Delegates` can _**only**_ perform wallet operations as authorized by the `Owner`.
* **Permission:** The authority granted within a `Cobo Account`. In other words, a user's ability to initiate certain Ethereum transactions from the smart contract wallet.
* **Role:** Each `Role` is associated with a set of `Permissions`. The `Owner` can pre-configure a set of `Permissions` for each `Role`, and then delegate a `Role` to the `Delegate` with the help of a `Role Manager`.
* **Role Manager:** A module that is used to manage each `Delegate` and its `Role.`Only the `Owner` is authorized to modify the settings of a `Role Manager`. In general, each `Cobo Account` will only have one `Role Manager`.
* **Authorizer:** A module that is used to examine the `Permissions` granted to a `Delegate`. The `Authorizer` will check the transactions sent by the `Delegate` according to the configuration of the `Owner`. Unauthorized transactions will be rejected by the `Authorizer`.

`Cobo Safe` ensures an easily adaptable and modular access control framework by combining built-in and customized `Authorizers`.

By leveraging `Cobo Safe`, Cobo Argus V2 effectively implements role-based access controls (RBAC) to enhance the transparency and flexibility in DeFi investments.
