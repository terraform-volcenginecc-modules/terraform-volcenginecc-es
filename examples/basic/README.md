# Basic ESCloud Example

## 1. Overview

Creates a development search cluster with one Hot data node, one Kibana node,
HTTPS, and private-only access. The caller supplies an existing VPC, subnet,
and the security controls used by workloads that reach the subnet.

## 2. Usage

```shell
terraform init
terraform plan
terraform apply
terraform plan
terraform destroy
```

Supply `admin_password` through a secret variable source. Confirm that the
second plan reports no changes.

## 3. Examples

This directory is the development single-data-node example. It does not claim
production availability.

## 4. Requirements

| Name | Version |
|---|---|
| Terraform | `>= 1.5.7` |
| OpenTofu | `>= 1.11.8` |

## 5. Providers

| Name | Source | Version |
|---|---|---|
| `volcenginecc` | `volcengine/volcenginecc` | `>= 0.0.60, < 0.1.0` |

## 6. Resources

| Name | Description |
|---|---|
| `terraform-volcenginecc-modules/es/volcenginecc` | Published ESCloud module |

## 7. Inputs

| Name | Description |
|---|---|
| `region` | Provider and cluster region |
| `cluster_name` | Development cluster name |
| `admin_password` | Sensitive cluster administrator password |
| `vpc_id`, `vpc_name` | Existing VPC identity |
| `subnet_id`, `subnet_name` | Existing subnet identity |
| `zone_id` | Availability zone containing the subnet |
| `hot_node_spec`, `kibana_node_spec` | Region-specific node specifications |
| `private_access_cidrs` | Trusted private CIDRs |

## 8. Outputs

| Name | Description |
|---|---|
| `cluster_id` | ESCloud cluster ID |
| `private_endpoints` | Private Elasticsearch and Kibana endpoints |

## 9. Notes

- VPC, subnet, and security groups remain caller-owned.
- Public Elasticsearch and Kibana endpoints are disabled.
- The Provider exposes no snapshot-policy or snapshot-repository resource.
