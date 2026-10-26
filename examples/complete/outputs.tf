output "cluster_id" {
  description = "High-availability ESCloud cluster ID."
  value       = module.es.cluster_id
}

output "cluster_status" {
  description = "Current cluster status."
  value       = module.es.cluster_status
}

output "cluster_endpoints" {
  description = "Private and any enabled public cluster endpoints."
  value       = module.es.cluster_endpoints
}

output "node_summary" {
  description = "Read-back node counts and specifications."
  value       = module.es.node_summary
}
