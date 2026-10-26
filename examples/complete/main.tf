provider "volcenginecc" {
  region = var.region
}

locals {
  private_allow_lists = {
    private_es = {
      type       = "PRIVATE_ES"
      allow_list = var.private_access_cidrs
    }
    private_kibana = {
      type       = "PRIVATE_KIBANA"
      allow_list = var.private_access_cidrs
    }
  }

  public_allow_lists = var.enable_public_access ? {
    public_es = {
      type       = "PUBLIC_ES"
      allow_list = var.public_access_cidrs
    }
    public_kibana = {
      type       = "PUBLIC_KIBANA"
      allow_list = var.public_access_cidrs
    }
  } : {}
}

module "es" {
  source  = "terraform-volcenginecc-modules/es/volcenginecc"
  version = "~> 1.0"

  region_id       = var.region
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  admin_password  = var.admin_password

  vpc_id      = var.vpc_id
  vpc_name    = var.vpc_name
  subnet_id   = var.primary_subnet_id
  subnet_name = var.primary_subnet_name
  zone_ids    = var.zone_ids

  enable_pure_master  = true
  deletion_protection = var.deletion_protection

  node_specs = {
    hot = {
      type               = "Hot"
      number             = 4
      resource_spec_name = var.hot_node_spec
      storage_spec_name  = "es.volume.essd.pl0"
      storage_size       = 20
    }
    master = {
      type               = "Master"
      number             = 3
      resource_spec_name = var.master_node_spec
      storage_spec_name  = "es.volume.essd.pl0"
      storage_size       = 20
    }
    coordinator = {
      type               = "Coordinator"
      number             = 2
      resource_spec_name = var.coordinator_node_spec
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

  public_access = {
    elasticsearch_enabled = var.enable_public_access
    kibana_enabled        = var.enable_public_access
    bandwidth_mbps        = var.public_bandwidth_mbps
  }

  ip_allow_lists = merge(local.private_allow_lists, local.public_allow_lists)

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
    Scenario    = "high-availability-search"
  }
}
