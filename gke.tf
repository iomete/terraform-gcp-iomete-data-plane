locals {
  node_pool_oauth_scopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/trace.append",
    "https://www.googleapis.com/auth/cloud-platform"
  ]
}

#########################################
# Create a GKE cluster with no node pool #
#########################################

resource "google_container_cluster" "primary" {
  provider   = google-beta
  project    = var.project_id
  depends_on = [google_project_service.enabled_apis]
  name       = var.cluster_name
  location   = var.zone
  network    = google_compute_network.vpc_network.name

  deletion_protection = false

  initial_node_count = 1

  node_config {
    oauth_scopes = local.node_pool_oauth_scopes
    machine_type = "e2-standard-4"
    disk_size_gb = 100
    resource_labels = local.tags
  }

  private_cluster_config {
    enable_private_nodes   = true
    master_ipv4_cidr_block = "10.1.0.0/28"
  }

  ip_allocation_policy {
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  cluster_autoscaling {
    enabled             = true
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
    resource_limits {
      resource_type = "cpu"
      minimum       = 2
      maximum       = 20
    }
    resource_limits {
      resource_type = "memory"
      minimum       = 15
      maximum       = 150
    }
    auto_provisioning_defaults {
      management {
        auto_repair  = true
        auto_upgrade = true
      }
      upgrade_settings {
        max_surge       = 2
        max_unavailable = 0
      }
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "STABLE"
  }

  maintenance_policy {
    recurring_window {
      start_time = "2023-01-01T09:00:00Z"
      end_time   = "2030-01-01T17:00:00Z"
      recurrence = "FREQ=MONTHLY;BYMONTHDAY=1"
    }
  }
}


#########################################
# Network 
#########################################
resource "google_compute_network" "vpc_network" {
  depends_on = [google_project_service.enabled_apis]
  name       = "${var.cluster_name}-network"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.cluster_name}-sn"
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.0.0/16"
  region        = var.location
}

resource "google_compute_router" "router" {
  name    = "${var.cluster_name}-router"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router_nat" "advanced-nat" {
  name                               = "${var.cluster_name}-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "ingress_self_all" {
  name          = "ingress-self-all-${var.cluster_name}"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "ingress_cluster_all" {
  name          = "ingress-cluster-all-${var.cluster_name}"
  network       = google_compute_network.vpc_network.id
  priority      = 1001
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "egress_all" {
  name               = "egress-all-${var.cluster_name}"
  network            = google_compute_network.vpc_network.id
  priority           = 1000
  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "all"
  }
}

