# Overview

`Cobo Safe` 是 Cobo Global 开发的开源智能合约钱包访问控制框架。这个框架允许智能合约钱包的主管人 `Owner` 将钱包的某些操作权限（如转账、特定智能合约交互等）授权给代理人 `Delegate` ，授权完成后 `Delegate` 可以代替 `Owner` 对钱包进行有限的操作。

`Cobo Safe` 框架主要概念
- **Cobo Account** 是 `Cobo Safe` 框架下的智能合约钱包账户。
- **Owner** 是 `Cobo Safe` 中的特权用户，也是钱包的实际控制人，可以对 `Cobo Account` 进行权限 `Permission` 的管理与配置。
- **Delegate** 是 `Cobo Safe` 中的低权限用户，可以在 `Owner` 配置完成后进行允许的有限操作。
- **Permission** 指操作 `Cobo Account` 的权限，具体来说是指发起特定以太坊交易的能力。
- **Role** 代表一组 `Permission` 的集合。`Owner` 可以预先配置每个 `Role` 下所具备的 `Permission`，并通过 `Role Manager` 授予 `Delegate` 相应的 `Role`，这样 `Delegate` 就具备的相应的 `Permission`。
- **Role Manager** 是用来管理 `Delegate` 与 `Role` 映射关系的模块，通常只有 `Owner` 有权进行修改。通常每个 `Cobo Account` 只使用一个 `Role Manager`。
- **Authorizer** 是用来检查 `Delegate` 操作权限的模块。`Authorizer` 会根据 `Owner` 的配置对 `Delegate` 发起的交易内容进行检查，并拒绝未授权的请求。

通过使用不同的 `Authorizer`，`Cobo Safe` 实现了一种模块化的、易订制的权限管理机制。Cobo Argus 平台基于 `Cobo Safe` 实现了基于角色的访问控制(Role-based Access Control) 为投资者在 DeFi 投资活动中提供透明、灵活的权限控制解决方案。