output "cluster_id" {
  description = "Development ESCloud cluster ID."
  value       = module.es.cluster_id
}

output "private_endpoints" {
  description = "Private Elasticsearch and Kibana endpoints."
  value = {
    elasticsearch = module.es.cluster_endpoints.elasticsearch_private
    kibana        = module.es.cluster_endpoints.kibana_private
  }
}
