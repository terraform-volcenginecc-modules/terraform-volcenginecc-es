# Complete ESCloud 示例

## 1. 概述

定义跨两个或三个可用区的生产导向高可用搜索集群。配置包含四个 Hot 数据节点、
三个专有 Master 节点、两个 Coordinator 节点、一个 Kibana 节点、HTTPS、
删除保护和私网 IP 白名单。公网入口默认关闭，仅可配合受限可信
CIDR 显式开启。

## 2. 用法

```shell
terraform init
terraform plan
terraform apply
terraform plan
```

请通过密钥变量来源传入 `admin_password`，并确认第二次 plan 显示无变更。
destroy 前，应使用 `-var='deletion_protection=false'` 完成 plan 和 apply，
然后使用同一变量执行 `terraform destroy`。白名单删除为异步任务：若命令在
实例删除阶段返回 `TaskIsRunning` 并以 exit 1 结束，等待该服务端任务完成后
直接重试同一条 destroy 命令；不要手动删除实例或 Terraform State。

## 3. 示例

本目录表示生产高可用拓扑。私网访问场景保持
`enable_public_access = false`。如需受控公网入口，将其设为 `true` 并提供
受限的 `public_access_cidrs`。

快照仓库属于集群创建后的运维集成：通过搜索引擎仓库 API 注册经审批的
TOS 后端，将其凭据保存在 Terraform State 之外，并验证恢复流程。当前
Provider 未提供快照仓库或快照策略资源，因此本模块不声明管理该配置。

## 4. 版本要求

| 名称 | 版本 |
|---|---|
| Terraform | `>= 1.5.7` |
| OpenTofu | `>= 1.11.8` |

## 5. Provider

| 名称 | 来源 | 版本 |
|---|---|---|
| `volcenginecc` | `volcengine/volcenginecc` | `>= 0.0.60, < 0.1.0` |

## 6. 资源

| 名称 | 说明 |
|---|---|
| `terraform-volcenginecc-modules/es/volcenginecc` | 已发布的 ESCloud 模块 |

## 7. 输入

| 名称 | 说明 |
|---|---|
| `region`、`cluster_name`、`cluster_version` | 集群标识和引擎版本 |
| `admin_password` | 敏感的集群管理员密码 |
| `deletion_protection` | 删除保护，默认开启 |
| `vpc_id`、`vpc_name` | 已有 VPC 标识 |
| `primary_subnet_id`、`primary_subnet_name` | 主可用区内已有 Subnet |
| `zone_ids` | 三个有序可用区 |
| `hot_node_spec`、`master_node_spec` | 数据节点和专有 Master 规格 |
| `coordinator_node_spec`、`kibana_node_spec` | Coordinator 和 Kibana 规格 |
| `private_access_cidrs` | 可信私网 CIDR |
| `enable_public_access`、`public_access_cidrs` | 显式受限公网访问 |
| `public_bandwidth_mbps` | 公网入口带宽 |

## 8. 输出

| 名称 | 说明 |
|---|---|
| `cluster_id`、`cluster_status` | 集群标识和状态 |
| `cluster_endpoints` | 私网及已开启的公网访问地址 |
| `node_summary` | 云端回读的节点拓扑 |

## 9. 注意事项

- VPC、主 Subnet 和安全组由调用方管理。当前 ESCloud 资源可接收 VPC 和
  Subnet，但没有安全组字段。
- 引擎版本、地域、可用区、VPC、Subnet、HTTPS 模式、专有 Master 模式和
  项目在 Provider Schema 中是创建时属性。
- `network_specs`、节点分配和管理员密码是 Optional+Computed 或 write-only
  字段。生产使用前，应在 apply 后执行一次二次 plan。
- Provider 的创建路径不会应用请求的维护窗口，因此本示例保留服务默认值，
  以确保首次 apply 后幂等。
- destroy 前必须先关闭删除保护。标准 destroy 会先删白名单再删实例；由于
  白名单删除是异步操作，服务端未完成时实例删除会返回 `TaskIsRunning`。
  等待服务端任务完成后重试 destroy，直至 Provider 确认实例不存在。
