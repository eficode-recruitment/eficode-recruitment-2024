terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = "eficode-recruitment-2024"
  region  = "europe-central2" # Europe - Warsaw
  zone    = "europe-central2-a"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_instance" "vm_instance" {
  name         = "eficode-vm"
  machine_type = "e2-micro"

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

