terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file(var.gcp_credentials_file)
  project     = var.gcp_project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
}

resource "google_service_account" "ansible_sa" {
  account_id = "ansible-sa"
  description = "Service account for Ansible"
}

resource "google_project_iam_member" "ansible_sa_viewer" {
  project = var.gcp_project_id
  role    = "roles/viewer"
  member = "serviceAccount:${google_service_account.ansible_sa.email}"
}

resource "google_service_account_key" "ansible_sa_key" {
  service_account_id = google_service_account.ansible_sa.name
  public_key_type = "TYPE_X509_PEM_FILE"
}

resource "local_file" "service_account_key" {
  filename = "./ansible/inventory/ansible-sa-key.json"
  content = base64decode(google_service_account_key.ansible_sa_key.private_key)
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_instance" "vm_instance" {
  name         = "eficode-vm"
  machine_type = var.gce_vm_type
  tags         = ["ssh", "http"]

  metadata = {
    ssh-keys  = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key)} \n${var.gce_ssh_user_eficode}:${file(var.gce_ssh_pub_key_eficode)}"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name

    access_config {
      // Give the VM an external IP address
    }
  }
}

resource "google_compute_firewall" "firewall-allow-ssh" {
  provider = google
  name     = "firewall-allow-ssh"
  network  = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "firewall-allow-http" {
  provider = google
  name     = "firewall-allow-http"
  network  = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["http"]
}

output "nat_ip" {
  description = "The public IP of the instance"
  value = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
}

resource "google_artifact_registry_repository" "artifactory" {
  location      = var.gcp_region
  repository_id = "containers"
  description   = "Weather App Docker repository"
  format        = "DOCKER"
}


output "webserver_url" {
  description = "The URL of the webserver"
  value       = join("", ["http://", google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip])
}
