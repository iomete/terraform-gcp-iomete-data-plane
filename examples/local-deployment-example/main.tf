# Pre-requisites:
# 1. Create a GCP project
# 2. Create a Cloud Storage bucket in the project (pay attention to the location of the bucket, it should be the same as the location of the cluster)


module "data-plane-gcp" {
  source                    = "../.." # for local testing

  # A unique cluster name for IOMETE. It should be unique within GCP project and compatible with GCP naming conventions (See: https://cloud.google.com/compute/docs/naming-resources)
  cluster_name              = "test-deployment"

  # Google Cloud project ID. This is a unique identifier for your project and can be found in the Google Cloud Console. Recommended to create a new project for IOMETE.
  project_id                    = "iomete-lakehouse1"

  # The region where the cluster and Cloud storage will be hosted
  location     = "us-central1"

  # The zone where the cluster will be hosted?
  zone = "us-central1-c"

  lakehouse_storage_bucket_name = "iom-test-lake"

  driver_min_node_count_per_pool = 1
  executor_min_node_count_per_pool = 1
}