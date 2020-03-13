

data "google_compute_network" "my-network" {
  name = "default"
  project= "spid-non-prod"
}
# ------------------------------------------------------------------------------
# CREATE THE MASTER INSTANCE
#

resource "google_sql_database_instance" "master" {
  depends_on = [null_resource.dependency_getter]

  provider         = "google-beta"
  name             = var.name
  project          = var.project_id
  region           = var.region
  database_version = var.engine

  settings {
    tier                        = var.machine_type
    activation_policy           = var.activation_policy
    authorized_gae_applications = var.authorized_gae_applications
    disk_autoresize             = var.disk_autoresize

    ip_configuration {
      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = lookup(authorized_networks.value, "name", null)
          value = authorized_networks.value.value
        }
      }

      ipv4_enabled    = var.enable_public_internet_access
      private_network = data.google_compute_network.my-network.self_link
      require_ssl     = var.require_ssl
    }

    location_preference {
      follow_gae_application = var.follow_gae_application
      zone                   = var.master_zone
    }

    backup_configuration {
      binary_log_enabled = var.mysql_binary_log_enabled
      enabled            = var.backup_enabled
      start_time         = var.backup_start_time
    }

    maintenance_window {
      day          = var.maintenance_window_day
      hour         = var.maintenance_window_hour
      update_track = var.maintenance_track
    }

    disk_size         = var.disk_size
    disk_type         = var.disk_type


    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    user_labels = var.custom_labels
  }

  # Default timeouts are 10 minutes, which in most cases should be enough.
  # Sometimes the database creation can, however, take longer, so we
  # increase the timeouts slightly.
  timeouts {
    create = var.resource_timeout
    delete = var.resource_timeout
    update = var.resource_timeout
  }
}

# ------------------------------------------------------------------------------
# CREATE A DATABASE
# ------------------------------------------------------------------------------


resource "google_sql_database" "default" {
  name       = var.db_name
  project    = var.project_id
  instance   = google_sql_database_instance.master.name
  charset    = var.db_charset
  collation  = var.db_collation
  depends_on = [google_sql_database_instance.master]
}


resource "google_sql_database" "additional_databases" {
  count      = length(var.additional_databases)
  project    = var.project_id
  name       = var.additional_databases[count.index]["name"]
  charset    = lookup(var.additional_databases[count.index], "charset", null)
  collation  = lookup(var.additional_databases[count.index], "collation", null)
  instance   = google_sql_database_instance.master.name
  depends_on = [google_sql_database_instance.master]
}

resource "google_sql_user" "default" {
  depends_on = [google_sql_database.default]
  project  = var.project_id
  name     = var.master_user_name
  instance = google_sql_database_instance.master.name
  host     = var.master_user_host
  password = var.master_user_password
}

resource "google_sql_user" "additional_users" {
  count   = length(var.additional_users)
  project = var.project_id
  name    = var.additional_users[count.index]["name"]
  password = var.master_user_password
  host     = var.master_user_host
  instance   = google_sql_database_instance.master.name
  depends_on = [google_sql_database.default]
}

resource "null_resource" "dependency_getter" {
  provisioner "local-exec" {
    command = "echo ${length(var.dependencies)}"
  }
}



# ------------------------------------------------------------------------------
# CREATE A TEMPLATE FILE TO SIGNAL ALL RESOURCES HAVE BEEN CREATED
# ------------------------------------------------------------------------------

data "template_file" "complete" {
  depends_on = [
    google_sql_database_instance.master,
    google_sql_database_instance.replicas,
    google_sql_database.default,
    google_sql_user.default,
  ]

  template = true
}
