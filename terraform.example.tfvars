# This file is an example of the terraform.tfvars file that should be created in the root of the project.

## Google Cloud Platform (GCP) configuration
gcp_project_id       = "GCP_PROJECT_ID"
gcp_region           = "europe-central2"
gcp_zone             = "europe-central2-a"
gcp_credentials_file = "~/.config/gcloud/application_default_credentials.json"

## VM configuration
gce_vm_type = "e2-micro"
gce_ssh_user = "eficode"
gce_ssh_pub_key = "id_rsa_internship.pub"
