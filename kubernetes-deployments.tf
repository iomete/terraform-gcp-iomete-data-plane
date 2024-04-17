
provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

resource "kubernetes_namespace" "iomete-system" {
  metadata {
    name = "iomete-system"
  }
}

resource "kubernetes_secret" "data-plane-secret" {
  metadata {
    name      = "iomete-cloud-settings"
    namespace = kubernetes_namespace.iomete-system.metadata[0].name
  }

  data = {
    "settings" = jsonencode({
      cloud   = "gcp",
      project = var.project_id,
      region  = var.location,
      zone    = var.zone,

      cluster_name          = var.cluster_name,
      storage_configuration = {
        lakehouse_bucket_name     = var.lakehouse_storage_bucket_name,
        lakehouse_service_account = google_service_account.lakehouse_service_account.email,
      },

      #info only
      gke = {
        name               = google_container_cluster.primary.name,
        endpoint           = google_container_cluster.primary.endpoint,
        self_link          = google_container_cluster.primary.self_link,
        caCert             = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate),
        "credentials.json" = base64decode(google_service_account_key.lakehouse_service_account_key.private_key)
      },
      terraform = {
        module_version = local.module_version
      },
    })
  }

  type = "opaque"

  depends_on = [
    google_container_cluster.primary
  ]
}

# =============== Istio Deployment ===============

resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio-base" {
  name       = "base"
  namespace  = kubernetes_namespace.istio-system.metadata.0.name
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = "1.17.2"
  chart      = "base"
}

resource "helm_release" "istio-istiod" {
  name       = "istiod"
  namespace  = kubernetes_namespace.istio-system.metadata.0.name
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = "1.17.2"
  chart      = "istiod"
  depends_on = [
    helm_release.istio-base
  ]
}

resource "helm_release" "istio-gateway" {
  name       = "istio-ingress"
  namespace  = kubernetes_namespace.istio-system.metadata.0.name
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = "1.17.2"
  chart      = "gateway"
  depends_on = [
    helm_release.istio-istiod
  ]
}