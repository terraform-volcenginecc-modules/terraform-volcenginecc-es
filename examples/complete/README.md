# Complete ESCloud Example

## 1. Overview

Defines a production-oriented, high-availability search cluster across two or
three availability zones. It uses four Hot data nodes, three dedicated Master
nodes, two Coordinator nodes, one Kibana node, HTTPS, deletion protection, and
private IP allowlists. Public endpoints remain off by
default and can be enabled only with restricted trusted CIDRs.

## 2. Usage

```shell
terraform init
terraform plan
terraform apply
terraform plan
```

Supply `admin_password` through a secret variable source. Confirm that the
second plan reports no changes. Before destroy, plan and apply with
`-var='deletion_protection=false'`, and then run `terraform destroy` with the
same variable. Allowlist deletion is asynchronous: if instance deletion
returns `TaskIsRunning` and the command exits with code 1, wait for the
service task to finish and rerun the same destroy command. Do not manually
remove the instance or Terraform state.

## 3. Examples

This directory represents a production high-availability topology. A private
access deployment keeps `enable_public_access = false`. For a controlled
public endpoint, set it to true and provide restricted `public_access_cidrs`.

A snapshot repository remains a post-create operational integration: register
an approved TOS-backed repository through the search engine repository API,
store its credentials outside Terraform state, and test restore procedures.
The current Provider does not expose a snapshot repository or snapshot policy
resource, so this module does not claim ownership of that configuration.

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
| `region`, `cluster_name`, `cluster_version` | Cluster identity and engine version |
| `admin_password` | Sensitive cluster administrator password |
| `deletion_protection` | Destroy protection, enabled by default |
| `vpc_id`, `vpc_name` | Existing VPC identity |
| `primary_subnet_id`, `primary_subnet_name` | Existing subnet in the primary zone |
| `zone_ids` | Two or three ordered availability zones |
| `hot_node_spec`, `master_node_spec` | Data and dedicated Master specifications |
| `coordinator_node_spec`, `kibana_node_spec` | Coordinator and Kibana specifications |
| `private_access_cidrs` | Trusted private CIDRs |
| `enable_public_access`, `public_access_cidrs` | Explicit restricted public access |
| `public_bandwidth_mbps` | Public endpoint bandwidth |

## 8. Outputs

| Name | Description |
|---|---|
| `cluster_id`, `cluster_status` | Cluster identity and status |
| `cluster_endpoints` | Private and enabled public endpoints |
| `node_summary` | Read-back node topology |

## 9. Notes

- VPC, primary subnet, and security groups remain caller-owned. The current
  ESCloud resource accepts VPC and subnet but no security group field.
- Engine version, region, zones, VPC, subnet, HTTPS mode, dedicated-Master
  mode, and project are create-only in the Provider schema.
- `network_specs`, node assignments, and the administrator password are
  Optional+Computed or write-only. Run a second plan after apply before
  relying on the configuration in production.
- The Provider create path does not apply a requested maintenance window, so
  this example keeps the service default to preserve first-apply idempotency.
- Deletion protection must be disabled before destroy. Standard destroy
  deletes allowlists before the instance; while that asynchronous task is
  incomplete, instance deletion returns `TaskIsRunning`. Wait for completion
  and rerun destroy until the Provider confirms the instance is absent.
