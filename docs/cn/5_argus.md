# Cobo Argus

[Cobo Argus](https://argus.cobo.com/) 是 `Cobo Global` 推出的 DeFi 投资管理工具。`Argus` 平台基于 `Cobo Safe` 实现了基于角色的访问控制(`Role-based Access Control`)，为投资者在 DeFi 投资活动中提供灵活的权限控制解决方案。

`Cobo Safe` 本身可以自由的配置各种类型的 `Authorizer` 与 `Role Manager` 来实现灵活的访问控制。但在 `Argus` 中，为了满足大多数人的普遍需求，使用了比较固定的配置。在 `Argus` 中 `Cobo Safe` 框架部署结构如下：

![](../argus.png)

`Argus` 中使用 `Cobo Safe Account` 管理 `Safe` 钱包的访问控制规则。`Cobo Safe Account`  使用 `ArgusRootAuthorizer` 作为顶层的 `Authorizer`。用户可以根据自己的需求，灵活的配置 `Role` 与 `子 Authorizer`。

在 `Argus` 中
- 一个 `Authorizer` 就用来表示一种交易权限 `Permission`
- 多个 `Authorizer` 绑定在同一个 `Role` 上表示为这个 `Role` 赋予了一个 `Permission` 集合
- 多种 `Role` 组合可固定形成一种预授权策略（称为 `Strategy`），方便 `Delegate` 来完成某个 DeFi 项目的预定义投资操作。`Argus` 中已经预定好了多种 `Strategy`，您可以在 `Strategy Marketplace` 中找到它们。

## Argus 中 Cobo Safe 工作流程

在 `Argus` 中用户与 `Cobo Safe` 的典型交互流程如下：

`Safe Owner` 进行对 `Delegate` 的授权：
1. 创建 `Cobo Safe Account` 并在 `Safe` 上启用 `Module`，并完成 `Argus Root Authorizer` 和 `Role Manager` 的安装及初始化。
2. 将 `Delegate` 地址添加到 `CoboSafeAccount` 的交易执行白名单中。
3. 将特定的权限 `Authorizer` 与设定的 `Role` 绑定在 `Argus Root Authorizer` 中
4. 在 `Role Manager` 中配置 `Delegate` 与 `Role` 绑定关系。

`Delegate` 执行交易：
1. `Delegate` 通过 `Cobo Safe Account` 发起交易。
2. `Cobo Safe Account` 检查 `Delegate` 是否在白名单列表中，如果不在则交易失败。如果成功则把交易交给 `Argus Root Authorizer` 处理。
3. `Argus Root Authorizer` 通过 `Role Manager` 找到 `Delegate` 所属的 `Role` 列表。
4. 在 `ArgusRootAuthorizer` 中遍历上述 `Role` 列表上，找到所绑定的一个或多个 `子 Authorizer`。
5. 遍历所有 `子 Authorizer` 进行检查，如果有任意 `Role` 的任意 `Authorizer` 检查通过，则交易放行，否则交易拒绝。
6. 交易放行后 `Cobo Safe Account` 调用 `Gnosis Safe` 发起实际的合约调用交易。
7. 交易调用完成后，`Argus Root Authorizer` 将进行 `postExecCheck`，流程与 3-5 基本一致。
8. 所有检查通过后`Delegate` 执行交易过程结束。

