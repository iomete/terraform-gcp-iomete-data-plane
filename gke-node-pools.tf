#########################################
# node pools #
#########################################

locals {
  driver_boot_disk_size_gb   = 100
  executor_boot_disk_size_gb = 50
  boot_disk_type             = "pd-ssd"

  drivers = {
    "driver-small" = {
      machine_type   = "e2-medium" # 2vCPU, 4GB RAM
    },
    "driver-medium" = {
      machine_type   = "e2-highmem-2" # 2vCPU, 16GB RAM
    },
    "driver-large" = {
      machine_type   = "e2-highmem-4" # 4vCPU, 32GB RAM
    }
  }

  executors = {
    "executor-small" = {
      machine_type   = "c2d-highmem-2" # 2vCPU, 16GB RAM, 375GB SSD
      local_ssd_count = 1
    },
    "executor-medium" = {
      machine_type   = "c2d-highmem-4" # 4vCPU, 32GB RAM, 375GB SSD
      local_ssd_count = 1
    },
    "executor-large" = {
      machine_type   = "c2d-highmem-8" # 8vCPU, 64GB RAM, 700GB SSD
      local_ssd_count = 2
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool
# https://cloud.google.com/kubernetes-engine/docs/reference/rest/v1beta1/projects.locations.clusters.nodePools
# https://cloud.google.com/kubernetes-engine/docs/reference/rest/v1beta1/NodeConfig
resource "google_container_node_pool" "driver" {
  for_each = local.drivers

  name           = each.key

  node_locations = [var.zone]
  cluster        = google_container_cluster.primary.id
  node_count     = var.driver_min_node_count_per_pool

  autoscaling {
    min_node_count = var.driver_min_node_count_per_pool
    max_node_count = var.driver_max_node_count_per_pool
  }

  node_config {
    machine_type = each.value.machine_type

    disk_size_gb = local.driver_boot_disk_size_gb
    disk_type    = local.boot_disk_type

    labels = {
      "k8s.iomete.com/node-purpose" = each.key
    }

    gvnic {
      enabled = true
    }

    taint {
      key    = "k8s.iomete.com/dedicated"
      value  = each.key
      effect = "NO_SCHEDULE"
    }

    taint {
      key    = "kubernetes.io/arch"
      value  = "arm64"
      effect = "NO_SCHEDULE"
    }

    resource_labels = local.tags

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.lakehouse_service_account.email
    oauth_scopes    = local.node_pool_oauth_scopes
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  timeouts {
    create = "30m"
    update = "20m"
  }
}

resource "google_container_node_pool" "executor" {
  for_each = local.executors

  name           = each.key

  node_locations = [var.zone]
  cluster        = google_container_cluster.primary.id
  node_count     = var.executor_min_node_count_per_pool

  autoscaling {
    min_node_count = var.executor_min_node_count_per_pool
    max_node_count = var.executor_max_node_count_per_pool
  }

  node_config {
    machine_type = each.value.machine_type

    disk_size_gb = local.executor_boot_disk_size_gb
    disk_type    = local.boot_disk_type

    ephemeral_storage_local_ssd_config {
      local_ssd_count = each.value.local_ssd_count
    }

    labels = {
      "k8s.iomete.com/node-purpose" = each.key
    }

    gvnic {
      enabled = true
    }

    taint {
      key    = "k8s.iomete.com/dedicated"
      value  = each.key
      effect = "NO_SCHEDULE"
    }

    taint {
      key    = "kubernetes.io/arch"
      value  = "arm64"
      effect = "NO_SCHEDULE"
    }

    resource_labels = local.tags

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.lakehouse_service_account.email
    oauth_scopes    = local.node_pool_oauth_scopes
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  timeouts {
    create = "30m"
    update = "20m"
  }
}