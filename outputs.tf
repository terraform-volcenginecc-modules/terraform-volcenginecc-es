output "cluster_id" {
  description = "ESCloud instance ID."
  value       = volcenginecc_escloud_instance.this.instance_id
}

output "cluster_status" {
  description = "Current ESCloud instance status."
  value       = volcenginecc_escloud_instance.this.status
}

output "cluster_endpoints" {
  description = "Private and public endpoints reported by ESCloud."
  value = {
    elasticsearch_private = volcenginecc_escloud_instance.this.es_private_endpoint
    elasticsearch_public  = volcenginecc_escloud_instance.this.es_public_endpoint
    kibana_private        = volcenginecc_escloud_instance.this.kibana_private_domain
    kibana_public         = volcenginecc_escloud_instance.this.kibana_public_domain
    cerebro_private       = volcenginecc_escloud_instance.this.cerebro_private_domain
    cerebro_public        = volcenginecc_escloud_instance.this.cerebro_public_domain
  }
}

output "network_access" {
  description = "Effective network access flags and attached EIP IDs reported by ESCloud."
  value = {
    elasticsearch_private_enabled = volcenginecc_escloud_instance.this.enable_es_private_network
    elasticsearch_public_enabled  = volcenginecc_escloud_instance.this.enable_es_public_network
    elasticsearch_eip_id          = volcenginecc_escloud_instance.this.es_eip_id
    kibana_private_enabled        = volcenginecc_escloud_instance.this.enable_kibana_private_network
    kibana_public_enabled         = volcenginecc_escloud_instance.this.enable_kibana_public_network
    kibana_eip_id                 = volcenginecc_escloud_instance.this.kibana_eip_id
  }
}

output "node_summary" {
  description = "Read-back node counts and storage/resource specifications."
  value = {
    total_nodes = volcenginecc_escloud_instance.this.total_nodes
    hot = {
      number        = volcenginecc_escloud_instance.this.instance_configuration.hot_node_number
      resource_spec = volcenginecc_escloud_instance.this.instance_configuration.hot_node_resource_spec
      storage_spec  = volcenginecc_escloud_instance.this.instance_configuration.hot_node_storage_spec
    }
    master = {
      number        = volcenginecc_escloud_instance.this.instance_configuration.master_node_number
      resource_spec = volcenginecc_escloud_instance.this.instance_configuration.master_node_resource_spec
      storage_spec  = volcenginecc_escloud_instance.this.instance_configuration.master_node_storage_spec
    }
    warm = {
      number        = volcenginecc_escloud_instance.this.instance_configuration.warm_node_number
      resource_spec = volcenginecc_escloud_instance.this.instance_configuration.warm_node_resource_spec
      storage_spec  = volcenginecc_escloud_instance.this.instance_configuration.warm_node_storage_spec
    }
    cold = {
      number        = volcenginecc_escloud_instance.this.instance_configuration.cold_node_number
      resource_spec = volcenginecc_escloud_instance.this.instance_configuration.cold_node_resource_spec
      storage_spec  = volcenginecc_escloud_instance.this.instance_configuration.cold_node_storage_spec
    }
    coordinator = {
      number        = volcenginecc_escloud_instance.this.instance_configuration.coordinator_node_number
      resource_spec = volcenginecc_escloud_instance.this.instance_configuration.coordinator_node_resource_spec
      storage_spec  = volcenginecc_escloud_instance.this.instance_configuration.coordinator_node_storage_spec
    }
    kibana = {
      number        = volcenginecc_escloud_instance.this.instance_configuration.kibana_node_number
      resource_spec = volcenginecc_escloud_instance.this.instance_configuration.kibana_node_resource_spec
    }
  }
}

output "ip_allow_list_ids" {
  description = "IP allowlist resource IDs keyed by stable logical name."
  value = {
    for key, allowlist in volcenginecc_escloud_ip_allow_list.this :
    key => allowlist.id
  }
}
