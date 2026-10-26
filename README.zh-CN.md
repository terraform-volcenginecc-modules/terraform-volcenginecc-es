# terraform-volcenginecc-es

## 1. 概述

面向日志检索、站内搜索、指标分析和全文检索的单个托管 ESCloud 搜索集群
Terraform 模块。模块管理集群拓扑、存储、HTTPS 模式、Kibana 节点、
公网入口意图、维护窗口、标签和 ESCloud IP 白名单。

调用方负责 Provider 凭据和地域配置，以及 VPC、Subnet、安全组和快照仓库。
ESCloud Provider 资源可接收 VPC 和 Subnet 标识，但没有安全组或快照策略字段。

## 2. 用法

```hcl
module "es" {
  source  = "terraform-volcenginecc-modules/es/volcenginecc"
  version = "~> 1.0"

  region_id      = "cn-beijing"
  cluster_name   = "application-search"
  admin_password = var.es_admin_password

  vpc_id      = "vpc-example"
  vpc_name    = "search-vpc"
  subnet_id   = "subnet-example"
  subnet_name = "search-primary"
  zone_ids    = ["cn-beijing-a"]

  node_specs = {
    data = {
      type               = "Hot"
      number             = 1
      resource_spec_name = "es.x2.medium"
      storage_size       = 20
    }
    dashboard = {
      type               = "Kibana"
      number             = 1
      resource_spec_name = "kibana.x2.small"
      storage_spec_name  = ""
      storage_size       = 0
    }
  }

  ip_allow_lists = {
    private_es = {
      type       = "PRIVATE_ES"
      allow_list = ["10.0.0.0/8"]
    }
  }
}
```

Provider 凭据和 `region` 应在调用方 root Module 中配置。

## 3. 示例

- `basic` 表示包含一个 Hot 数据节点和 Kibana 的私网开发集群。
- `complete` 表示多可用区高可用配置，包含专有 Master、Coordinator、
  Kibana、私网访问和可选的受限公网访问。
- complete 示例以文字描述创建后的快照仓库集成。由于 Provider 没有对应
  资源，因此不新增专项示例目录。

## 4. 版本要求

| 名称 | 版本 |
|---|---|
| Terraform | `>= 1.5.7` |
| OpenTofu | `>= 1.11.8` |
| `volcengine/volcenginecc` | `>= 0.0.60, < 0.1.0` |

## 5. Provider

| 名称 | 来源 |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 6. 资源

| 名称 | 说明 |
|---|---|
| `volcenginecc_escloud_instance.this` | 托管搜索集群 |
| `volcenginecc_escloud_ip_allow_list.this` | 按稳定 key 管理的私网或公网 IP 白名单 |

## 7. 输入

| 名称 | 说明 | 默认值 |
|---|---|---|
| `region_id` | 集群地域，必须与 Provider 地域一致 | 必填 |
| `cluster_name` | 搜索集群名称 | 必填 |
| `cluster_version` | 引擎版本 | `V7_10` |
| `vpc_id`、`vpc_name` | 调用方管理的 VPC 标识 | 必填 |
| `subnet_id`、`subnet_name` | 调用方管理的主 Subnet 标识 | 必填 |
| `zone_ids` | 有序可用区，第一个为主可用区 | 必填 |
| `admin_password` | 敏感、只写的管理员密码 | 必填 |
| `configuration_code` | ESCloud 计费配置码 | `es.standard` |
| `charge_type` | `PostPaid` 或 `PrePaid` | `PostPaid` |
| `period`、`auto_renew` | 预付费购买时长和续费配置 | `null`、`false` |
| `project_name` | 已有项目 | `default` |
| `enable_https` | 开启 HTTPS | `true` |
| `enable_pure_master` | 要求专有 Master 角色 | `false` |
| `deletion_protection` | 开启集群删除保护 | `false` |
| `node_specs` | 按稳定 key 定义节点角色、数量、计算和存储 | 必填 |
| `public_access` | Elasticsearch 和 Kibana 公网入口配置 | 关闭 |
| `ip_allow_lists` | 按稳定 key 定义 ESCloud IP 白名单 | `{}` |
| `allow_unrestricted_public_access` | 显式允许公网全网 CIDR | `false` |
| `maintenance_days`、`maintenance_time` | 维护窗口 | 空 |
| `tags` | 集群标签 | `{}` |

## 8. 输出

| 名称 | 说明 |
|---|---|
| `cluster_id` | ESCloud 实例 ID |
| `cluster_status` | 当前实例状态 |
| `cluster_endpoints` | Elasticsearch、Kibana 和 Cerebro 访问地址 |
| `network_access` | 云端生效的私网/公网状态和 EIP ID |
| `node_summary` | 云端回读的节点拓扑 |
| `ip_allow_list_ids` | 按逻辑 key 返回的白名单 ID |

## 9. 注意事项

- 本模块管理一个 ESCloud 实例及其 IP 白名单。VPC、Subnet、安全组、
  项目和快照仓库由调用方管理。
- 当前 Cloud Control Schema 中，引擎版本、地域、可用区、VPC、Subnet、
  HTTPS 模式、专有 Master 模式和项目是创建时属性。
- 修改 `node_specs` 或 `ip_allow_lists` 的 map key 会改变 Terraform 地址。
  白名单 type 也必须唯一，其导入 ID 为 `instance_id|type`。
- ESCloud 要求每个白名单至少有一个自定义组。省略 `groups` 时，模块会使用
  默认 CIDR 创建 `terraform-managed` 组。
- 服务端会注入 Provider 无法与用户标签区分的 `sys:tag:createdBy`。模块在
  创建时设置标签，后续忽略标签差异，以避免永久的原地更新计划。
- 公网入口默认关闭。开启任一入口都要求 HTTPS 和匹配的非空公网白名单。
  全网 CIDR 还需显式开启不受限访问选项。
- `network_specs`、`node_specs_assigns` 和 `admin_password` 是
  Optional+Computed 或 write-only 字段。生产使用前，应在 apply 后执行一次
  二次 plan。
- Provider `0.0.71` 在创建时不会应用维护窗口。要求首次 apply 后幂等时应
  保持该配置为空。
- 已有集群可导入 `volcenginecc_escloud_instance.this`。已有白名单可导入
  `volcenginecc_escloud_ip_allow_list.this["key"]`，导入值为
  `instance_id|type`。
- destroy 前必须关闭删除保护并 apply。ESCloud 白名单删除为异步任务：标准
  destroy 会先删除白名单，紧接着删除实例；若服务端尚未完成白名单任务，实例
  删除会返回 `TaskIsRunning` 并使本次 destroy 以 exit 1 结束。此时不要手动
  删除实例或 State；等待服务端任务完成后，以相同配置重新执行
  `terraform destroy`。销毁成功后，Provider 删除处理器会持续查询，直至确认
  集群不存在。
- Provider `0.0.71` 没有快照策略或快照仓库资源，因此该能力延后。应通过
  经审批的运维流程配置和验证，且不得将仓库凭据写入 Terraform State。
- Provider `0.0.71` 可能在刷新后的 State 和 destroy plan 中暴露
  `admin_password`。Provider 将该字段修复为 sensitive/write-only 前，不得持久化
  原始 plan 日志。
