variable "region" {
  description = "Volcengine region for the Provider and cluster."
  type        = string
  default     = "cn-beijing"
}

variable "cluster_name" {
  description = "Name of the high-availability search cluster."
  type        = string
  default     = "complete-search"
}

variable "cluster_version" {
  description = "ESCloud engine version."
  type        = string
  default     = "V7_10"
}

variable "admin_password" {
  description = "Administrator password for the cluster."
  type        = string
  sensitive   = true
}

variable "deletion_protection" {
  description = "Protect the production cluster from deletion. Set false and apply before destroy."
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "ID of the existing VPC."
  type        = string
}

variable "vpc_name" {
  description = "Name of the existing VPC."
  type        = string
}

variable "primary_subnet_id" {
  description = "ID of the existing subnet in the first, primary zone."
  type        = string
}

variable "primary_subnet_name" {
  description = "Name of the existing subnet in the primary zone."
  type        = string
}

variable "zone_ids" {
  description = "Two or three ordered availability zones; the first contains the supplied subnet."
  type        = list(string)

  validation {
    condition     = length(var.zone_ids) >= 2 && length(var.zone_ids) <= 3 && length(distinct(var.zone_ids)) == length(var.zone_ids)
    error_message = "zone_ids must contain two or three unique availability zones."
  }
}

variable "hot_node_spec" {
  description = "Available ESCloud specification for Hot data nodes."
  type        = string
  default     = "es.x2.medium"
}

variable "master_node_spec" {
  description = "Available ESCloud specification for dedicated Master nodes."
  type        = string
  default     = "es.x2.medium"
}

variable "coordinator_node_spec" {
  description = "Available ESCloud specification for Coordinator nodes."
  type        = string
  default     = "es.x2.medium"
}

variable "kibana_node_spec" {
  description = "Available ESCloud specification for the Kibana node."
  type        = string
  default     = "kibana.x2.small"
}

variable "private_access_cidrs" {
  description = "Trusted VPC CIDRs allowed to access Elasticsearch and Kibana privately."
  type        = set(string)
  default     = ["10.0.0.0/8"]
}

variable "enable_public_access" {
  description = "Enable Elasticsearch and Kibana public endpoints for trusted CIDRs."
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "Trusted public CIDRs used only when enable_public_access is true."
  type        = set(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.public_access_cidrs :
      can(cidrhost(cidr, 0)) && !contains(["0.0.0.0/0", "::/0"], cidr)
    ])
    error_message = "public_access_cidrs must contain valid restricted CIDRs, not internet-wide routes."
  }
}

variable "public_bandwidth_mbps" {
  description = "Bandwidth for each enabled public endpoint."
  type        = number
  default     = 10

  validation {
    condition     = var.public_bandwidth_mbps >= 1 && floor(var.public_bandwidth_mbps) == var.public_bandwidth_mbps
    error_message = "public_bandwidth_mbps must be a positive whole number."
  }
}
