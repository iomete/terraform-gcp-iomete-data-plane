output "gke_name" {
  description = "The name of the cluster master. This output is used for interpolation with node pools, other modules."
  value       = google_container_cluster.primary.name
}

output "gke_cluster_id" {
  value       = google_container_cluster.primary.id
  description = "An identifier for the resource with format projects/{{project}}/locations/{{zone}}/clusters/{{name}}"
}


# gcloud container clusters get-credentials my-lakehouse-cluster --zone us-central1-c --project iom-prj1
output "gke_connection_command" {
  description = "gcloud command to connect to the GKE cluster."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.location} --project ${data.google_client_config.default.project}"
}