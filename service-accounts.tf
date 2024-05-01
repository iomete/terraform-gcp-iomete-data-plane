resource "google_service_account" "lakehouse_service_account" {
  depends_on   = [google_project_service.enabled_apis]
  account_id   = var.cluster_name
  display_name = "Lakehouse Service Account for ${var.cluster_name}"
}

resource "google_service_account_key" "lakehouse_service_account_key" {
  service_account_id = google_service_account.lakehouse_service_account.account_id
}

resource "google_project_iam_member" "container_admin" {
  project = data.google_client_config.default.project
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.lakehouse_service_account.email}"
}

resource "google_service_account_iam_binding" "workload_identity" {
  depends_on         = [google_container_cluster.primary]
  service_account_id = google_service_account.lakehouse_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  members            = [
    "serviceAccount:${data.google_client_config.default.project}.svc.id.goog[iomete-system/lakehouse-service-account]",
  ]
}

# Grant the service account the ability to read/write to the storage bucket
resource "google_storage_bucket_iam_member" "lakehouse_storage_member_add" {
  depends_on = [google_project_service.enabled_apis]

  bucket = var.lakehouse_storage_bucket_name
  role   = "roles/storage.objectAdmin"

  member = "serviceAccount:${google_service_account.lakehouse_service_account.email}"
}