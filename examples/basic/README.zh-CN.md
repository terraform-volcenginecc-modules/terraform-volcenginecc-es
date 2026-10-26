# Basic ESCloud 示例

## 1. 概述

创建开发用途的搜索集群，包含一个 Hot 数据节点、一个 Kibana 节点、
HTTPS 和仅私网访问。调用方提供已有 VPC、Subnet，以及工作负载访问该
Subnet 时使用的安全控制。

## 2. 用法

```shell
terraform init
terraform plan
terraform apply
terraform plan
terraform destroy
```

请通过密钥变量来源传入 `admin_password`，并确认第二次 plan 显示无变更。

## 3. 示例

本目录是开发单数据节点示例，不声明生产可用性。

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
| `region` | Provider 和集群地域 |
| `cluster_name` | 开发集群名称 |
| `admin_password` | 敏感的集群管理员密码 |
| `vpc_id`、`vpc_name` | 已有 VPC 标识 |
| `subnet_id`、`subnet_name` | 已有 Subnet 标识 |
| `zone_id` | Subnet 所在可用区 |
| `hot_node_spec`、`kibana_node_spec` | 地域内可用的节点规格 |
| `private_access_cidrs` | 可信私网 CIDR |

## 8. 输出

| 名称 | 说明 |
|---|---|
| `cluster_id` | ESCloud 集群 ID |
| `private_endpoints` | Elasticsearch 和 Kibana 私网地址 |

## 9. 注意事项

- VPC、Subnet 和安全组仍由调用方管理。
- Elasticsearch 和 Kibana 公网入口均关闭。
- Provider 当前没有快照策略或快照仓库资源。
