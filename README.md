# terraform-volcenginecc-es

## 1. Overview

Terraform module for one managed ESCloud search cluster used for log search,
site search, metric analysis, and full-text retrieval. It manages the cluster
topology, storage, HTTPS mode, Kibana node, public endpoint intent, maintenance
window, tags, and ESCloud IP allowlists.

The caller owns provider authentication and region configuration, plus the
VPC, subnet, security groups, and any snapshot repository. The ESCloud
Provider resource accepts VPC and subnet identifiers but exposes no security
group or snapshot-policy field.

## 2. Usage

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

Provider credentials and `region` belong in the caller root module.

## 3. Examples

- `basic` represents a private development cluster with one Hot data node and
  Kibana.
- `complete` represents a multi-zone high-availability configuration with
  dedicated Master and Coordinator nodes, Kibana, private access, and optional
  restricted public access.
- Snapshot repository integration is described as a post-create workflow in
  the complete example. No dedicated example directory is added because the
  Provider has no corresponding resource.

## 4. Requirements

| Name | Version |
|---|---|
| Terraform | `>= 1.5.7` |
| OpenTofu | `>= 1.11.8` |
| `volcengine/volcenginecc` | `>= 0.0.60, < 0.1.0` |

## 5. Providers

| Name | Source |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 6. Resources

| Name | Description |
|---|---|
| `volcenginecc_escloud_instance.this` | The managed search cluster |
| `volcenginecc_escloud_ip_allow_list.this` | Stable-keyed private or public IP allowlists |

## 7. Inputs

| Name | Description | Default |
|---|---|---|
| `region_id` | Cluster region; must match the Provider region | Required |
| `cluster_name` | Search cluster name | Required |
| `cluster_version` | Engine version | `V7_10` |
| `vpc_id`, `vpc_name` | Caller-owned VPC identity | Required |
| `subnet_id`, `subnet_name` | Caller-owned primary subnet identity | Required |
| `zone_ids` | Ordered zones; first is primary | Required |
| `admin_password` | Sensitive write-only administrator password | Required |
| `configuration_code` | ESCloud billing configuration | `es.standard` |
| `charge_type` | `PostPaid` or `PrePaid` | `PostPaid` |
| `period`, `auto_renew` | Prepaid purchase and renewal settings | `null`, `false` |
| `project_name` | Existing project | `default` |
| `enable_https` | Enable HTTPS | `true` |
| `enable_pure_master` | Require a dedicated Master role | `false` |
| `deletion_protection` | Protect the cluster from deletion | `false` |
| `node_specs` | Stable-keyed node roles, counts, compute, and storage | Required |
| `public_access` | Elasticsearch and Kibana public endpoint settings | Disabled |
| `ip_allow_lists` | Stable-keyed ESCloud IP allowlists | `{}` |
| `allow_unrestricted_public_access` | Explicit opt-in for internet-wide public CIDRs | `false` |
| `maintenance_days`, `maintenance_time` | Maintenance schedule | Empty |
| `tags` | Cluster tags | `{}` |

## 8. Outputs

| Name | Description |
|---|---|
| `cluster_id` | ESCloud instance ID |
| `cluster_status` | Current instance status |
| `cluster_endpoints` | Elasticsearch, Kibana, and Cerebro endpoints |
| `network_access` | Effective private/public flags and EIP IDs |
| `node_summary` | Read-back node topology |
| `ip_allow_list_ids` | Allowlist IDs keyed by logical name |

## 9. Notes

- This module owns one ESCloud instance and its configured IP allowlists.
  VPC, subnet, security groups, projects, and snapshot repositories remain
  caller-owned.
- Engine version, region, zones, VPC, subnet, HTTPS mode, dedicated-Master
  mode, and project are create-only in the current Cloud Control schema.
- Changing a `node_specs` or `ip_allow_lists` map key changes its Terraform
  address. Allowlist type values must also remain unique because the import ID
  is `instance_id|type`.
- ESCloud requires at least one custom group on each allowlist. When `groups`
  is omitted, the module creates `terraform-managed` with the default CIDRs.
- The service injects a `sys:tag:createdBy` tag that the Provider cannot
  distinguish from user tags. Tags are applied on create and ignored for
  subsequent diffs to prevent a perpetual in-place update.
- Public endpoints default to disabled. Enabling either endpoint requires
  HTTPS and a matching non-empty public allowlist. Internet-wide CIDRs require
  the explicit unrestricted-access opt-in.
- `network_specs`, `node_specs_assigns`, and `admin_password` are
  Optional+Computed or write-only. Run a second plan after apply before
  relying on the configuration in production.
- Provider `0.0.71` does not apply maintenance settings during create. Leave
  them unset when first-apply idempotency is required.
- Existing clusters can be imported at
  `volcenginecc_escloud_instance.this`. Existing allowlists can be imported at
  `volcenginecc_escloud_ip_allow_list.this["key"]` with `instance_id|type`.
- Deletion protection must be disabled and applied before destroy. ESCloud
  allowlist deletion is asynchronous: a standard destroy first deletes
  allowlists and then immediately requests instance deletion. If the service
  has not completed the allowlist task, instance deletion returns
  `TaskIsRunning` and the destroy exits with code 1. Do not manually remove
  the instance or Terraform state; wait for the service task to finish and
  rerun `terraform destroy` with the same configuration. After deletion is
  accepted, the Provider delete handler queries until the instance is absent.
- Snapshot policy and repository ownership are deferred because Provider
  `0.0.71` exposes neither resource. Configure and test them through an
  approved operational workflow without placing repository credentials in
  Terraform state.
- Provider `0.0.71` can expose `admin_password` in refreshed state and destroy
  plans. Do not persist raw plan logs until the Provider marks this field
  sensitive and write-only.
