
resource "google_compute_instance" "redis" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone
  tags          = ["redis"]
  metadata_startup_script = var.startup_script

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
service_account {
    email  = var.email
    scopes = ["cloud-platform","compute-rw"]
  }
 network_interface {
    network            = var.network
    subnetwork         = var.subnetwork
    subnetwork_project = var.subnetwork_project
    network_ip = var.network_ip
  }
}



