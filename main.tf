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

