# IOMETE Data-Plane module

Terraform module to create infrastructure on GCP (Google Cloud Platform) for IOMETE Data-Plane.

The module is open-source and available on GitHub: https://github.com/iomete/terraform-gcp-iomete-data-plane

## Data plane installation

### Pre-requisites

Make sure you have the following tools installed on your machine:

- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [Terraform CLI](https://www.terraform.io/downloads.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

### Configure Terraform file

Create a new folder and create a file (e.g. `main.tf`) with the following content:

> **_Important:_**  Update the `project`, `region`, `zone`, `cluster_name` and `lakehouse_bucket_name` values according to your configuration.

```hcl
provider "google" {
  # Google Cloud project ID. This is a unique identifier for your project and can be found in the Google Cloud Console. Recommended to create a new project for IOMETE.
  project = "<gcp-project-id>"
  # The region where the cluster and Cloud storage will be hosted
  region  = "us-central1"    # Cluster installed region
  # The zone where the cluster will be hosted (e.g. us-central1-c)
  zone    = "us-central1-c" # Cluster installed exact zone
}

module "iomete-data-plane" {
  source  = "iomete/iomete-data-plane/gcp"
  version = "~> 1.1.0"

  # A user provided cluster name for IOMETE. It should be unique within GCP project and compatible with GCP naming conventions (See: https://cloud.google.com/compute/docs/naming-resources)
  cluster_name          = "my-lakehouse"
  # Create a Cloud Storage bucket inside the GCP the project (pay attention to the location of the bucket, it should be the same as the location of the cluster) and provide the name here
  lakehouse_bucket_name = "<lakehouse-bucket-name>"
}

output "gke_connection_command" {
  value = module.iomete-data-plane.gke_connection_command
}
```

Required variables:

| Name                      | Description                                                                                                                                                                                                                                                                     | Example                                                                                                 |
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| **cluster_name**          | A user provided unique cluster name for IOMETE. It should be unique within GCP project and compatible with GCP naming conventions (See: https://cloud.google.com/compute/docs/naming-resources).                                                                                | my-lakehouse                                                                                            |
| **lakehouse_bucket_name** | An empty Google Cloud Storage bucket to store the data for the lakehouse. Go to your project in the Google Cloud Console, navigate to Cloud Storage and create a new bucket. Pay attention to the location of the bucket, it should be the same as the location of the cluster. | Create a bucket in the GCP project. Make sure that bucket is located in the same region as the cluster. |

For all available variables, see the [variables.tf](https://github.com/iomete/terraform-gcp-iomete-data-plane/blob/main/variables.tf) file.

### Run terraform

Once you have the terraform file, and configured it according to your needs, you can run the following commands to
create the data-plane infrastructure:

```shell
# Initialize Terraform
terraform init -upgrade

# Create a plan to see what resources will be created
terraform plan

# Apply the changes to your AWS account
terraform apply
```

Please, make sure terraform state files are stored on a secure location. State can be stored in a git, S3 bucket, or any
other secure location.
See here [Managing Terraform State – Best Practices & Examples](https://spacelift.io/blog/terraform-state) for more
details.
