

locals {
  hostname      = var.hostname == "" ? "default" : var.hostname
  num_instances = length(var.static_ips) == 0 ? var.num_instances : length(var.static_ips)

  # local.static_ips is the same as var.static_ips with a dummy element appended
  # at the end of the list to work around "list does not have any elements so cannot
  # determine type" error when var.static_ips is empty
  static_ips = concat(var.static_ips, ["NOT_AN_IP"])

  instance_group_count = min(
    local.num_instances,
    length(data.google_compute_zones.available.names),
  )
}

###############
# Data Sources
###############

data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
  status  = "UP"
}

#############
# Instances
#############


resource "google_compute_instance_group" "instance_group" {
  provider = google
  count    = local.instance_group_count
  name     = "${local.hostname}-instance-group-${format("%03d", count.index + 1)}"
  project  = var.project_id
  zone     =  var.zone
  instances = var.instances

  dynamic "named_port" {
    for_each = var.named_ports
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }
}

