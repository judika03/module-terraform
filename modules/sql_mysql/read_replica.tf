
resource "google_sql_database_instance" "replicas" {
  count                = var.read_replica_size
  project              = var.project_id
  name                 = "${var.name}-replica${count.index}"
  database_version     = var.engine
  region               = var.region
  master_instance_name = google_sql_database_instance.master.name
  dynamic "replica_configuration" {
    for_each = [var.read_replica_configuration]
    content {
      ca_certificate            = lookup(replica_configuration.value, "ca_certificate", null)
      client_certificate        = lookup(replica_configuration.value, "client_certificate", null)
      client_key                = lookup(replica_configuration.value, "client_key", null)
      connect_retry_interval    = lookup(replica_configuration.value, "connect_retry_interval", null)
      dump_file_path            = lookup(replica_configuration.value, "dump_file_path", null)
      failover_target           = lookup(replica_configuration.value, "failover_target", false)
      master_heartbeat_period   = lookup(replica_configuration.value, "master_heartbeat_period", null)
      password                  = lookup(replica_configuration.value, "password", null)
      ssl_cipher                = lookup(replica_configuration.value, "ssl_cipher", null)
      username                  = lookup(replica_configuration.value, "username", null)
      verify_server_certificate = lookup(replica_configuration.value, "verify_server_certificate", null)
    }
  }

  settings {
    tier              = var.read_replica_tier
    activation_policy = var.read_replica_activation_policy
       ip_configuration {
      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.value
        }
      }

      ipv4_enabled    = var.enable_public_internet_access
      private_network =  data.google_compute_network.my-network.self_link
      require_ssl     = var.require_ssl
    }

    authorized_gae_applications = var.authorized_gae_applications

    crash_safe_replication = var.read_replica_crash_safe_replication
    disk_autoresize        = var.read_replica_disk_autoresize
    disk_size              = var.read_replica_disk_size
    disk_type              = var.read_replica_disk_type
    pricing_plan           = var.read_replica_pricing_plan
    replication_type       = var.read_replica_replication_type
    user_labels            = var.read_replica_user_labels
    dynamic "database_flags" {
      for_each = var.read_replica_database_flags
      content {
        name  = lookup(database_flags.value, "name", null)
        value = lookup(database_flags.value, "value", null)
      }
    }

      location_preference {
      follow_gae_application = var.follow_gae_application
      zone                   = element(var.read_replica_zones, count.index)
    }


    maintenance_window {
      day          = var.read_replica_maintenance_window_day
      hour         = var.read_replica_maintenance_window_hour
      update_track = var.read_replica_maintenance_window_update_track
    }
  }

  depends_on = [google_sql_database_instance.master]

  lifecycle {
    ignore_changes = [
      settings[0].disk_size
    ]
  }

  timeouts {
    create = var.create_timeout
    update = var.update_timeout
    delete = var.delete_timeout
  }
}


