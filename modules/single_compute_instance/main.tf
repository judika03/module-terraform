
resource "google_compute_instance" "server" {
  name         = "${var.name}-${each.key}"
  machine_type = each.value["machine_type"]
  zone         = var.zone
  tags         = var.tags
  allow_stopping_for_update = true
  for_each = var.instances_list
  metadata_startup_script = each.value["startup"]

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
    network_ip = each.value["network_ip"]
  }
}

resource "google_compute_firewall" "tcp" {
  name    = var.names
  network = var.network
  allow {
    protocol = "tcp"
    ports    = var.ports
  }
  target_tags   = ["firewall-tcp"]
  source_ranges = var.source_ranges
}


