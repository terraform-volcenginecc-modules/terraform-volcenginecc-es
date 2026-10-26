provider "volcenginecc" {
  region = var.region
}

module "es" {
  source  = "terraform-volcenginecc-modules/es/volcenginecc"
  version = "~> 1.0"

  region_id      = var.region
  cluster_name   = var.cluster_name
  admin_password = var.admin_password

  vpc_id      = var.vpc_id
  vpc_name    = var.vpc_name
  subnet_id   = var.subnet_id
  subnet_name = var.subnet_name
  zone_ids    = [var.zone_id]

  node_specs = {
    data = {
      type               = "Hot"
      number             = 1
      resource_spec_name = var.hot_node_spec
      storage_spec_name  = "es.volume.essd.pl0"
      storage_size       = 20
    }
    dashboard = {
      type               = "Kibana"
      number             = 1
      resource_spec_name = var.kibana_node_spec
      storage_spec_name  = ""
      storage_size       = 0
    }
  }

  ip_allow_lists = {
    private_es = {
      type       = "PRIVATE_ES"
      allow_list = var.private_access_cidrs
    }
    private_kibana = {
      type       = "PRIVATE_KIBANA"
      allow_list = var.private_access_cidrs
    }
  }

  tags = {
    Environment = "development"
    ManagedBy   = "Terraform"
    Scenario    = "single-data-node-search"
  }
}
