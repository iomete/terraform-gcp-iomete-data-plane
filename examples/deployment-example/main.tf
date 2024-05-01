provider "google" {
  # Google Cloud project ID. This is a unique identifier for your project and can be found in the Google Cloud Console. Recommended to create a new project for IOMETE.
  project = "iom-prj1"
  # The region where the cluster and Cloud storage will be hosted
  region  = "us-central1"
  # The zone where the cluster will be hosted (e.g. us-central1-c)
  zone = "us-central1-c"
}

module "iomete-data-plane" {
  source  = "iomete/iomete-data-plane/gcp"
  version               = "~> 1.1.0"

  # A user provided cluster name for IOMETE. It should be unique within GCP project and compatible with GCP naming conventions (See: https://cloud.google.com/compute/docs/naming-resources)
  cluster_name = "my-lakehouse-cluster"

  # Create a Cloud Storage bucket inside the GCP the project (pay attention to the location of the bucket, it should be the same as the location of the cluster) and provide the name here
  lakehouse_storage_bucket_name = "iom-lakehouse-bucket1"
}

output "gke_connection_command" {
  value = module.iomete-data-plane.gke_connection_command
}