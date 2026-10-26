variable "region_id" {
  description = "Region of the ESCloud instance. It must match the caller's provider region. Changing it replaces the instance."
  type        = string
  nullable    = false

  validation {
    condition     = trimspace(var.region_id) != ""
    error_message = "region_id must be non-empty."
  }
}

variable "cluster_name" {
  description = "Name of the managed search cluster."
  type        = string
  nullable    = false

  validation {
    condition     = length(var.cluster_name) >= 1 && length(var.cluster_name) <= 128
    error_message = "cluster_name must contain 1 to 128 characters."
  }
}

variable "cluster_version" {
  description = "Search engine version accepted by ESCloud, for example V7_10. Changing it replaces the instance."
  type        = string
  default     = "V7_10"
  nullable    = false

  validation {
    condition     = trimspace(var.cluster_version) != ""
    error_message = "cluster_version must be non-empty."
  }
}

variable "vpc_id" {
  description = "ID of the caller-owned VPC. Changing it replaces the instance."
  type        = string
  nullable    = false

  validation {
    condition     = trimspace(var.vpc_id) != ""
    error_message = "vpc_id must be non-empty."
  }
}

variable "vpc_name" {
  description = "Name of the caller-owned VPC supplied to ESCloud."
  type        = string
  nullable    = false

  validation {
    condition     = trimspace(var.vpc_name) != ""
    error_message = "vpc_name must be non-empty."
  }
}

variable "subnet_id" {
  description = "ID of the caller-owned subnet in the primary availability zone. Changing it replaces the instance."
  type        = string
  nullable    = false

  validation {
    condition     = trimspace(var.subnet_id) != ""
    error_message = "subnet_id must be non-empty."
  }
}

variable "subnet_name" {
  description = "Name of the caller-owned subnet supplied to ESCloud."
  type        = string
  nullable    = false

  validation {
    condition     = trimspace(var.subnet_name) != ""
    error_message = "subnet_name must be non-empty."
  }
}

variable "zone_ids" {
  description = "Ordered availability zones. The first zone is primary; changing the comma-joined value replaces the instance."
  type        = list(string)
  nullable    = false

  validation {
    condition = (
      length(var.zone_ids) >= 1 &&
      length(var.zone_ids) <= 3 &&
      length(distinct(var.zone_ids)) == length(var.zone_ids) &&
      alltrue([for zone_id in var.zone_ids : trimspace(zone_id) != "" && !strcontains(zone_id, ",")])
    )
    error_message = "zone_ids must contain one to three unique, non-empty zone IDs without commas."
  }
}

variable "admin_password" {
  description = "Administrator password sent to ESCloud. The Provider treats it as write-only; keep it in a secret store."
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition = (
      length(var.admin_password) >= 8 &&
      length(var.admin_password) <= 32 &&
      can(regex("[A-Z]", var.admin_password)) &&
      can(regex("[a-z]", var.admin_password)) &&
      can(regex("[0-9]", var.admin_password))
    )
    error_message = "admin_password must be 8 to 32 characters and contain uppercase, lowercase, and numeric characters."
  }
}

variable "configuration_code" {
  description = "ESCloud billing configuration code."
  type        = string
  default     = "es.standard"
  nullable    = false

  validation {
    condition     = trimspace(var.configuration_code) != ""
    error_message = "configuration_code must be non-empty."
  }
}

variable "charge_type" {
  description = "Billing mode: PostPaid or PrePaid."
  type        = string
  default     = "PostPaid"
  nullable    = false

  validation {
    condition     = contains(["PostPaid", "PrePaid"], var.charge_type)
    error_message = "charge_type must be PostPaid or PrePaid."
  }
}

variable "period" {
  description = "Purchase duration in months for a PrePaid cluster."
  type        = number
  default     = null

  validation {
    condition     = var.period == null ? true : (var.period >= 1 && floor(var.period) == var.period)
    error_message = "period must be a positive whole number when set."
  }
}

variable "auto_renew" {
  description = "Whether a PrePaid cluster renews automatically."
  type        = bool
  default     = false
  nullable    = false
}

variable "project_name" {
  description = "Existing project that owns the cluster. Changing it replaces the instance."
  type        = string
  default     = "default"
  nullable    = false

  validation {
    condition     = trimspace(var.project_name) != ""
    error_message = "project_name must be non-empty."
  }
}

variable "enable_https" {
  description = "Use HTTPS for cluster access. Changing it replaces the instance in the current Provider schema."
  type        = bool
  default     = true
  nullable    = false
}

variable "enable_pure_master" {
  description = "Use dedicated Master nodes. Changing it replaces the instance."
  type        = bool
  default     = false
  nullable    = false
}

variable "deletion_protection" {
  description = "Protect the cluster from deletion. Disable and apply this setting before destroying the cluster."
  type        = bool
  default     = false
  nullable    = false
}

variable "node_specs" {
  description = "Node roles keyed by stable logical names. Each role type may occur once."
  type = map(object({
    type               = string
    number             = number
    resource_spec_name = string
    storage_spec_name  = optional(string, "es.volume.essd.pl0")
    storage_size       = optional(number, 100)
    throughput         = optional(number, 0)
  }))
  nullable = false

  validation {
    condition     = length(var.node_specs) > 0
    error_message = "node_specs must contain at least one node role."
  }

  validation {
    condition = (
      length(distinct([for spec in values(var.node_specs) : spec.type])) == length(var.node_specs) &&
      alltrue([
        for spec in values(var.node_specs) :
        contains(["Hot", "Master", "Kibana", "Coordinator", "Warm", "Cold"], spec.type) &&
        trimspace(spec.resource_spec_name) != ""
      ])
    )
    error_message = "Each node role type must be unique and use Hot, Master, Kibana, Coordinator, Warm, or Cold with a non-empty resource specification."
  }

  validation {
    condition = alltrue([
      for spec in values(var.node_specs) :
      spec.number == floor(spec.number) && (
        spec.type == "Hot" ? spec.number >= 1 && spec.number <= 100 :
        spec.type == "Master" ? spec.number == 3 :
        spec.type == "Kibana" ? spec.number == 1 :
        spec.type == "Coordinator" ? spec.number >= 2 && spec.number <= 50 :
        spec.type == "Warm" ? spec.number >= 3 && spec.number <= 100 :
        spec.number >= 2 && spec.number <= 100
      )
    ])
    error_message = "Node counts must meet role limits: Hot 1-100, Master 3, Kibana 1, Coordinator 2-50, Warm 3-100, and Cold 2-100."
  }

  validation {
    condition = alltrue([
      for spec in values(var.node_specs) :
      spec.type == "Kibana" ? (
        spec.storage_size == 0 && spec.storage_spec_name == ""
        ) : (
        spec.storage_size >= 20 &&
        spec.storage_size == floor(spec.storage_size) &&
        spec.storage_size % 10 == 0 &&
        trimspace(spec.storage_spec_name) != ""
      )
    ])
    error_message = "Kibana storage must be size 0 with an empty specification; other roles require storage of at least 20 GiB in 10 GiB increments."
  }

  validation {
    condition = alltrue([
      for spec in values(var.node_specs) :
      spec.throughput >= 0 && spec.throughput == floor(spec.throughput) && spec.throughput % 10 == 0
    ])
    error_message = "Node throughput must be zero or a positive whole number in 10 MiB increments."
  }
}

variable "public_access" {
  description = "Explicit public endpoint configuration. Both endpoints are disabled by default."
  type = object({
    elasticsearch_enabled = optional(bool, false)
    kibana_enabled        = optional(bool, false)
    bandwidth_mbps        = optional(number, 1)
    spec_name             = optional(string, "es.eip.bgp_fixed_bandwidth")
  })
  default  = {}
  nullable = false

  validation {
    condition = (
      var.public_access.bandwidth_mbps >= 1 &&
      floor(var.public_access.bandwidth_mbps) == var.public_access.bandwidth_mbps &&
      trimspace(var.public_access.spec_name) != ""
    )
    error_message = "public_access requires a positive whole-number bandwidth_mbps and a non-empty spec_name."
  }
}

variable "ip_allow_lists" {
  description = "ESCloud IP allowlists keyed by stable logical names. Each network type may occur once. An omitted groups map creates a terraform-managed group with the default CIDRs because the Provider requires at least one group."
  type = map(object({
    type       = string
    allow_list = set(string)
    groups     = optional(map(set(string)), {})
  }))
  default  = {}
  nullable = false

  validation {
    condition = (
      length(distinct([for item in values(var.ip_allow_lists) : item.type])) == length(var.ip_allow_lists) &&
      alltrue([
        for item in values(var.ip_allow_lists) :
        contains(["PRIVATE_ES", "PRIVATE_KIBANA", "PUBLIC_ES", "PUBLIC_KIBANA"], item.type) &&
        length(item.allow_list) > 0 &&
        alltrue([for cidr in item.allow_list : can(cidrhost(cidr, 0))]) &&
        alltrue(flatten([
          for group_name, cidrs in item.groups : concat(
            [trimspace(group_name) != "" && length(cidrs) > 0],
            [for cidr in cidrs : can(cidrhost(cidr, 0))]
          )
        ]))
      ])
    )
    error_message = "Each allowlist type must be unique and valid; default and named groups require valid, non-empty CIDR sets."
  }
}

variable "allow_unrestricted_public_access" {
  description = "Explicit opt-in for 0.0.0.0/0 or ::/0 in PUBLIC_ES or PUBLIC_KIBANA allowlists."
  type        = bool
  default     = false
  nullable    = false
}

variable "maintenance_days" {
  description = "Optional maintenance weekdays."
  type        = set(string)
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for day in var.maintenance_days :
      contains(["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"], day)
    ])
    error_message = "maintenance_days must use uppercase weekday names."
  }
}

variable "maintenance_time" {
  description = "Optional maintenance window in HH:MM-HH:MM format."
  type        = string
  default     = null

  validation {
    condition     = var.maintenance_time == null ? true : can(regex("^([01][0-9]|2[0-3]):[0-5][0-9]-([01][0-9]|2[0-3]):[0-5][0-9]$", var.maintenance_time))
    error_message = "maintenance_time must use HH:MM-HH:MM format."
  }
}

variable "tags" {
  description = "Tags applied to the cluster."
  type        = map(string)
  default     = {}
  nullable    = false

  validation {
    condition = (
      length(var.tags) <= 50 &&
      alltrue([
        for key, value in var.tags :
        length(key) >= 1 && length(key) <= 128 &&
        key == trimspace(key) &&
        length(value) <= 256 &&
        value == trimspace(value)
      ])
    )
    error_message = "tags supports at most 50 entries; keys must be 1-128 characters and values at most 256 characters without surrounding spaces."
  }
}
