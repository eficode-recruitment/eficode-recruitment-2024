resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
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
  target_tags   = ["http"]
}

output "nat_ip" {
  description = "The public IP of the instance"
  value       = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
}
