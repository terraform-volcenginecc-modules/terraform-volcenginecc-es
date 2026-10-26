variable "region" {
  description = "Volcengine region for the Provider and cluster."
  type        = string
  default     = "cn-beijing"
}

variable "cluster_name" {
  description = "Name of the development search cluster."
  type        = string
  default     = "basic-search"
}

variable "admin_password" {
  description = "Administrator password for the cluster."
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "ID of the existing VPC."
  type        = string
}

variable "vpc_name" {
  description = "Name of the existing VPC."
  type        = string
}

variable "subnet_id" {
  description = "ID of the existing subnet in the cluster zone."
  type        = string
}

variable "subnet_name" {
  description = "Name of the existing subnet."
  type        = string
}

variable "zone_id" {
  description = "Availability zone containing the subnet."
  type        = string
  default     = "cn-beijing-a"
}

variable "hot_node_spec" {
  description = "Available ESCloud specification for the Hot data node."
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
