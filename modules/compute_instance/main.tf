
locals {
  hostname      = var.hostname == "" ? "default" : var.hostname
  num_instances = length(var.static_ips) == 0 ? var.num_instances : length(var.static_ips)

  static_ips = concat(var.static_ips, ["NOT_AN_IP"])
}

###############
# Data Sources
###############

data "google_compute_zones" "available" {
  region = var.region
}

#############
# Instances
#############

resource "google_compute_instance_from_template" "compute_instance" {
  provider = google
  count    = local.num_instances
  name     = "${local.hostname}-${format("%03d", count.index + 1)}"
  zone     = data.google_compute_zones.available.names[count.index % length(data.google_compute_zones.available.names)]

  network_interface {
    network            = var.network
    subnetwork         = var.subnetwork
    subnetwork_project = var.subnetwork_project
    network_ip         = length(var.static_ips) == 0 ? "" : element(local.static_ips, count.index)
  }

  source_instance_template = var.instance_template
}

