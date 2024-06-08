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

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_instance" "vm_instance" {
  name         = "eficode-vm"
  machine_type = var.gce_vm_type
  tags         = ["ssh"]

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

output "nat_ip" {
  description = "The public IP of the instance"
  value = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
}
