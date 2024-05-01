provider "google" {
  # Google Cloud project ID. This is a unique identifier for your project and can be found in the Google Cloud Console. Recommended to create a new project for IOMETE.
  project = "iomete-lakehouse1"
  # The region where the cluster and Cloud storage will be hosted
  region  = "us-central1"
  # The zone where the cluster will be hosted (e.g. us-central1-c)
  zone = "us-central1-c"
}

module "iomete-data-plane" {
  source = "../.." # for local testing

  # A unique cluster name for IOMETE. It should be unique within GCP project and compatible with GCP naming conventions (See: https://cloud.google.com/compute/docs/naming-resources)
  cluster_name = "test-deployment3"

  # Create a Cloud Storage bucket in the project (pay attention to the location of the bucket, it should be the same as the location of the cluster)
  lakehouse_storage_bucket_name = "iom-test-lake"
}

output "gke_connection_command" {
  value = module.iomete-data-plane.gke_connection_command
}