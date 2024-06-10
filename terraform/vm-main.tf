resource "google_compute_instance" "vm_instance" {
  name         = "eficode-vm"
  machine_type = var.gce_vm_type
  tags         = ["ssh", "http"]

  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key)} \n${var.gce_ssh_user_eficode}:${file(var.gce_ssh_pub_key_eficode)}"
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

output "webserver_url" {
  description = "The URL of the webserver"
  value       = join("", ["http://", google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip])
}
