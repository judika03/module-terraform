
###############
# Data Sources
###############
data "google_compute_image" "image" {
  project = var.source_image != "" ? var.source_image_project : "centos-cloud"
  name    = var.source_image != "" ? var.source_image : "centos-6-v20180716"
}

data "google_compute_image" "image_family" {
  project = var.source_image_family != "" ? var.source_image_project : "centos-cloud"
  family  = var.source_image_family != "" ? var.source_image_family : "centos-6"
}

#########
# Locals
#########

locals {
  boot_disk = [
    {
      source_image = var.source_image != "" ? data.google_compute_image.image.self_link : data.google_compute_image.image_family.self_link
      disk_size_gb = var.disk_size_gb
      disk_type    = var.disk_type
      auto_delete  = var.auto_delete
      boot         = "true"
    },
  ]

  all_disks = concat(local.boot_disk, var.additional_disks)

  
  shielded_vm_configs = var.enable_shielded_vm ? [true] : []
}

resource "google_service_account" "instance-group" {
  account_id = "redis-test"
  display_name = "instance-group"
  project      = "${var.project_id}"
}

####################
# Instance Template 
####################
resource "google_compute_instance_template" "tpl" {
  name_prefix             = "${var.name_prefix}-"
  project                 = var.project_id
  machine_type            = var.machine_type
  labels                  = var.labels
  metadata                = var.metadata
  tags                    = var.tags
  can_ip_forward          = var.can_ip_forward
  metadata_startup_script = var.startup_script
  region                  = var.region
  dynamic "disk" {
    for_each = local.all_disks
    content {
      auto_delete  = lookup(disk.value, "auto_delete", null)
      boot         = lookup(disk.value, "boot", null)
      device_name  = lookup(disk.value, "device_name", null)
      disk_name    = lookup(disk.value, "disk_name", null)
      disk_size_gb = lookup(disk.value, "disk_size_gb", null)
      disk_type    = lookup(disk.value, "disk_type", null)
      interface    = lookup(disk.value, "interface", null)
      mode         = lookup(disk.value, "mode", null)
      source       = lookup(disk.value, "source", null)
      source_image = lookup(disk.value, "source_image", null)
      type         = lookup(disk.value, "type", null)
    }
  }
  service_account {
    email  = google_service_account.instance-group.email
    scopes = ["cloud-platform","compute-rw"]
  }

  network_interface {
    network            = var.network
    subnetwork         = var.subnetwork
    subnetwork_project = var.subnetwork_project
    network_ip = var.network_ip

  }

  lifecycle {
    create_before_destroy = "true"
  }

  # scheduling must have automatic_restart be false when preemptible is true.
  scheduling {
    preemptible       = var.preemptible
    automatic_restart = ! var.preemptible
  }
  

  dynamic "shielded_instance_config" {
    for_each = local.shielded_vm_configs
    content {
      enable_secure_boot          = lookup(var.shielded_instance_config, "enable_secure_boot", shielded_instance_config.value)
      enable_vtpm                 = lookup(var.shielded_instance_config, "enable_vtpm", shielded_instance_config.value)
      enable_integrity_monitoring = lookup(var.shielded_instance_config, "enable_integrity_monitoring", shielded_instance_config.value)
    }
  }
}
