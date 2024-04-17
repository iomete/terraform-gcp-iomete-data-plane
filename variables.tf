variable "cluster_name" {
  type        = string
  description = "A unique cluster name for IOMETE. It should be unique within GCP project and compatible with GCP naming conventions (See: https://cloud.google.com/compute/docs/naming-resources)."
}

variable "project_id" {
  type        = string
  description = "Your Google Cloud project ID. This is a unique identifier for your project and can be found in the Google Cloud Console. Recommended to create a new project for IOMETE."
}

variable "location" {
  type        = string
  description = "The region where the cluster and Cloud storage will be hosted"
}

variable "zone" {
  type        = string
  description = "The zone where the cluster will be hosted"
}

variable "lakehouse_storage_bucket_name" {
  type        = string
  description = "An empty Google Cloud Storage bucket to store the data for the lakehouse. Go to your project in the Google Cloud Console, navigate to Cloud Storage and create a new bucket. Pay attention to the location of the bucket, it should be the same as the location of the cluster."
}

########################
# node pools variables #
########################
variable "driver_min_node_count_per_pool" {
  type        = number
  description = "Minimum number of nodes in the per driver node pool"
  default     = 0
}

variable "driver_max_node_count_per_pool" {
  type        = number
  description = "Maximum number of nodes in the driver node pool"
  default     = "20"
}

variable "executor_min_node_count_per_pool" {
  type        = number
  description = "Minimum number of nodes in the exec node pool"
  default     = 0
}

variable "executor_max_node_count_per_pool" {
  type        = number
  description = "Maximum number of nodes in the exec node pool"
  default     = "200"
}

