locals {
  node_specs = [
    for key in sort(keys(var.node_specs)) : {
      type               = var.node_specs[key].type
      number             = var.node_specs[key].number
      resource_spec_name = var.node_specs[key].resource_spec_name
      storage_spec_name  = var.node_specs[key].storage_spec_name
      storage_size       = var.node_specs[key].storage_size
      extra_performance = {
        throughput = var.node_specs[key].throughput
      }
    }
  ]

  network_specs = [
    {
      type      = "Elasticsearch"
      is_open   = var.public_access.elasticsearch_enabled
      bandwidth = var.public_access.bandwidth_mbps
      spec_name = var.public_access.spec_name
    },
    {
      type      = "Kibana"
      is_open   = var.public_access.kibana_enabled
      bandwidth = var.public_access.bandwidth_mbps
      spec_name = var.public_access.spec_name
    },
  ]

  public_allowlist_cidrs = flatten([
    for item in values(var.ip_allow_lists) :
    contains(["PUBLIC_ES", "PUBLIC_KIBANA"], item.type) ? concat(
      tolist(item.allow_list),
      flatten([for cidrs in values(item.groups) : tolist(cidrs)])
    ) : []
  ])
}

resource "volcenginecc_escloud_instance" "this" {
  maintenance_day  = length(var.maintenance_days) == 0 ? null : var.maintenance_days
  maintenance_time = var.maintenance_time

  instance_configuration = {
    instance_name       = var.cluster_name
    version             = var.cluster_version
    region_id           = var.region_id
    zone_id             = join(",", var.zone_ids)
    charge_type         = var.charge_type
    period              = var.period
    auto_renew          = var.auto_renew
    configuration_code  = var.configuration_code
    project_name        = var.project_name
    enable_https        = var.enable_https
    enable_pure_master  = var.enable_pure_master
    deletion_protection = var.deletion_protection
    admin_password      = var.admin_password
    node_specs_assigns  = local.node_specs
    network_specs       = local.network_specs

    vpc = {
      vpc_id   = var.vpc_id
      vpc_name = var.vpc_name
    }

    subnet = {
      subnet_id   = var.subnet_id
      subnet_name = var.subnet_name
    }

    tags = [
      for key in sort(keys(var.tags)) : {
        key   = key
        value = var.tags[key]
      }
    ]
  }

  lifecycle {
    ignore_changes = [instance_configuration.tags]

    precondition {
      condition = contains(
        [for spec in values(var.node_specs) : spec.type],
        "Hot"
      )
      error_message = "node_specs must define one Hot data-node role."
    }

    precondition {
      condition = (
        !var.enable_pure_master ||
        contains([for spec in values(var.node_specs) : spec.type], "Master")
      )
      error_message = "enable_pure_master requires one Master role in node_specs."
    }

    precondition {
      condition = (
        var.enable_pure_master ||
        !contains([for spec in values(var.node_specs) : spec.type], "Master")
      )
      error_message = "A Master role requires enable_pure_master to be true."
    }

    precondition {
      condition     = var.charge_type == "PrePaid" ? var.period != null : var.period == null && !var.auto_renew
      error_message = "PrePaid requires period; PostPaid requires period to be null and auto_renew to be false."
    }

    precondition {
      condition = (
        !var.public_access.elasticsearch_enabled ||
        (
          var.enable_https &&
          anytrue([
            for item in values(var.ip_allow_lists) :
            item.type == "PUBLIC_ES" && length(item.allow_list) > 0
          ])
        )
      )
      error_message = "Public Elasticsearch access requires HTTPS and a non-empty PUBLIC_ES allowlist."
    }

    precondition {
      condition = (
        !var.public_access.kibana_enabled ||
        (
          var.enable_https &&
          anytrue([
            for item in values(var.ip_allow_lists) :
            item.type == "PUBLIC_KIBANA" && length(item.allow_list) > 0
          ])
        )
      )
      error_message = "Public Kibana access requires HTTPS and a non-empty PUBLIC_KIBANA allowlist."
    }

    precondition {
      condition = (
        var.allow_unrestricted_public_access ||
        length(setintersection(
          toset(local.public_allowlist_cidrs),
          toset(["0.0.0.0/0", "::/0"])
        )) == 0
      )
      error_message = "Public allowlists cannot contain 0.0.0.0/0 or ::/0 unless allow_unrestricted_public_access is true."
    }
  }
}

resource "volcenginecc_escloud_ip_allow_list" "this" {
  for_each = var.ip_allow_lists

  instance_id = volcenginecc_escloud_instance.this.instance_id
  type        = each.value.type
  allow_list  = each.value.allow_list
  groups = length(each.value.groups) == 0 ? [
    {
      name       = "terraform-managed"
      allow_list = each.value.allow_list
    }
    ] : [
    for name in sort(keys(each.value.groups)) : {
      name       = name
      allow_list = each.value.groups[name]
    }
  ]
}
