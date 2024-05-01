data "google_client_config" "default" {}

locals {
  module_version   = "1.0.1"
  api_services_map = {
    "compute.googleapis.com" = true,
    "iam.googleapis.com" = true,
    "container.googleapis.com" = true
  }

  tags = {
    "iomete-cluster-name" : var.cluster_name
    "iomete-terraform" : true
    "iomete-managed" : true
  }
}

#########################################
# enable apis #
#########################################
resource "google_project_service" "enabled_apis" {
  for_each                   = local.api_services_map
  project                    = data.google_client_config.default.project
  service                    = each.key
  disable_on_destroy         = true
  disable_dependent_services = true
}