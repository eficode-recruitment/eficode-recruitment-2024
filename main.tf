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
  machine_type = "e2-micro"
  tags         = ["ssh"]

  metadata = {
    ssh-keys = "kubakazik611@gmail.com:${file("./id_rsa_internship.pub")}"
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

