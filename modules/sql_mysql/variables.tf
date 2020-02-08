# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "project_id" {
  description = "The project ID to host the database in."
  type        = string
}

variable "region" {
  description = "The region to host the database in."
  type        = string
}

variable "name" {
  description = "The name of the database instance. Note, after a name is used, it cannot be reused for up to one week. Use lowercase letters, numbers, and hyphens. Start with a letter."
  type        = string
}

variable "engine" {
  description = "The engine version of the database, e.g. `MYSQL_5_6` or `MYSQL_5_7`. See https://cloud.google.com/sql/docs/features for supported versions."
  type        = string
}

variable "machine_type" {
  description = "The machine type for the instances. See this page for supported tiers and pricing: https://cloud.google.com/sql/pricing"
  type        = string
}



variable "db_name" {
  description = "Name of your database. Needs to follow MySQL identifier rules: https://dev.mysql.com/doc/refman/5.7/en/identifiers.html"
  type        = string
}

variable "master_user_name" {
  description = "The username part for the default user credentials, i.e. 'master_user_name'@'master_user_host' IDENTIFIED BY 'master_user_password'. This should typically be set as the environment variable TF_VAR_master_user_name so you don't check it into source control."
  type        = string
}

variable "master_user_password" {
  description = "The password part for the default user credentials, i.e. 'master_user_name'@'master_user_host' IDENTIFIED BY 'master_user_password'. This should typically be set as the environment variable TF_VAR_master_user_password so you don't check it into source control."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------

variable "activation_policy" {
  description = "This specifies when the instance should be active. Can be either `ALWAYS`, `NEVER` or `ON_DEMAND`."
  type        = string
  default     = "ALWAYS"
}

variable "authorized_networks" {
  description = "A list of authorized CIDR-formatted IP address ranges that can connect to this DB. Only applies to public IP instances."
  type        = list(map(string))
  default     = []

  # Example:
  #
  # authorized_networks = [
  #   {
  #     name = "all-inbound" # optional
  #     value = "0.0.0.0/0"
  #   }
  # ]
}

variable "authorized_gae_applications" {
  description = "A list of Google App Engine (GAE) project names that are allowed to access this instance."
  type        = list(string)
  default     = []
}

variable "backup_enabled" {
  description = "Set to false if you want to disable backup."
  type        = bool
  default     = true
}

variable "backup_start_time" {
  description = "HH:MM format (e.g. 04:00) time indicating when backup configuration starts. NOTE: Start time is randomly assigned if backup is enabled and 'backup_start_time' is not set"
  type        = string
  default     = "04:00"
}

variable "mysql_binary_log_enabled" {
  description = "Set to false if you want to disable binary logs - only applicable to MySQL. Note, when using failover or read replicas, master and existing backups need to have binary_log_enabled=true set."
  type        = bool
  default     = true
}

variable "maintenance_window_day" {
  description = "Day of week (1-7), starting on Monday, on which system maintenance can occur. Performance may be degraded or there may even be a downtime during maintenance windows."
  type        = number
  default     = 7
}

variable "maintenance_window_hour" {
  description = "Hour of day (0-23) on which system maintenance can occur. Ignored if 'maintenance_window_day' not set. Performance may be degraded or there may even be a downtime during maintenance windows."
  type        = number
  default     = 7
}

variable "maintenance_track" {
  description = "Receive updates earlier (canary) or later (stable)."
  type        = string
  default     = "stable"
}

variable "db_charset" {
  description = "The charset for the default database."
  type        = string
  default     = null
}

variable "db_collation" {
  description = "The collation for the default database. Example for MySQL databases: 'utf8_general_ci'."
  type        = string
  default     = null
}

variable "database_flags" {
  description = "List of Cloud SQL flags that are applied to the database server"
  type        = list(any)
  default     = []

  # Example:
  #
  # database_flags = [
  #  {
  #    name  = "auto_increment_increment"
  #    value = "10"
  #  },
  #  {
  #    name  = "auto_increment_offset"
  #    value = "5"
  #  },
  #]
}


variable "user_host" {
  description = "The host for the default user"
  type        = string
  default     = "%"
}




variable "disk_autoresize" {
  description = "Second Generation only. Configuration to increase storage size automatically."
  type        = bool
  default     = true
}

variable "disk_size" {
  description = "Second generation only. The size of data disk, in GB. Size of a running instance cannot be reduced but can be increased."
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "The type of storage to use. Must be one of `PD_SSD` or `PD_HDD`."
  type        = string
  default     = "PD_SSD"
}

variable "follow_gae_application" {
  description = "A GAE application whose zone to remain in. Must be in the same region as this instance."
  type        = string
  default     = null
}

variable "master_zone" {
  description = "Preferred zone for the master instance (e.g. 'us-central1-a'). 'region'. If null, Google will auto-assign a zone."
  type        = string
  default     = null
}

variable "master_user_host" {
  description = "The host part for the default user, i.e. 'master_user_name'@'master_user_host' IDENTIFIED BY 'master_user_password'. Don't set this field for Postgres instances."
  type        = string
  default     = "%"
}

# In nearly all cases, databases should NOT be publicly accessible, however if you're migrating from a PAAS provider like Heroku to GCP, this needs to remain open to the internet.
variable "enable_public_internet_access" {
  description = "WARNING: - In nearly all cases a database should NOT be publicly accessible. Only set this to true if you want the database open to the internet."
  type        = bool
  default     = false
}

variable "enable_failover_replica" {
  description = "Set to true to enable failover replica."
  type        = bool
  default     = false
}

variable "mysql_failover_replica_zone" {
  description = "The preferred zone for the failover instance (e.g. 'us-central1-b'). Must be different than 'master_zone'. Only applicable to MySQL, Postgres will determine this automatically."
  type        = string
  default     = null
}

variable "require_ssl" {
  description = "True if the instance should require SSL/TLS for users connecting over IP. Note: SSL/TLS is needed to provide security when you connect to Cloud SQL using IP addresses. If you are connecting to your instance only by using the Cloud SQL Proxy or the Java Socket Library, you do not need to configure your instance to use SSL/TLS."
  type        = bool
  default     = false
}

variable "private_network" {
  description = "The resource link for the VPC network from which the Cloud SQL instance is accessible for private IP."
  type        = string
  default     = null
}

variable "num_read_replicas" {
  description = "The number of read replicas to create. Cloud SQL will replicate all data from the master to these replicas, which you can use to horizontally scale read traffic."
  type        = number
  default     = 0
}

variable "read_replica_zones" {
  description = "A list of compute zones where read replicas should be created. List size should match 'num_read_replicas'"
  type        = list(string)
  default     = []

  # Example:
  #  default = ["us-central1-b", "us-central1-c"]
}

variable "custom_labels" {
  description = "A map of custom labels to apply to the instance. The key is the label name and the value is the label value."
  type        = map(string)
  default     = {}
}

# Resources are created sequentially. Therefore we increase the default timeouts considerably
# to not have the operations time out.
variable "resource_timeout" {
  description = "Timeout for creating, updating and deleting database instances. Valid units of time are s, m, h."
  type        = string
  default     = "60m"
}

# ---------------------------------------------------------------------------------------------------------------------

variable "dependencies" {
  description = "Create a dependency between the resources in this module to the interpolated values in this list (and thus the source resources). In other words, the resources in this module will now depend on the resources backing the values in this list such that those resources need to be created before the resources in this module, and the resources in this module need to be destroyed before the resources in the list."
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------------------------------------------------------------
# Variable read replica


variable "read_replica_configuration" {
  description = "The replica configuration for use in all read replica instances."
  type = object({
    connect_retry_interval    = number
    dump_file_path            = string
    ca_certificate            = string
    client_certificate        = string
    client_key                = string
    failover_target           = bool
    master_heartbeat_period   = number
    password                  = string
    ssl_cipher                = string
    username                  = string
    verify_server_certificate = bool
  })

  default = {
    connect_retry_interval    = null
    dump_file_path            = null
    ca_certificate            = null
    client_certificate        = null
    client_key                = null
    failover_target           = null
    master_heartbeat_period   = null
    password                  = null
    ssl_cipher                = null
    username                  = null
    verify_server_certificate = null
  }
}

variable "read_replica_name_suffix" {
  description = "The optional suffix to add to the read instance name"
  type        = string
  default     = ""
}

variable "read_replica_size" {
  description = "The size of read replicas"
  type        = number
  default     = 0
}

variable "read_replica_tier" {
  description = "The tier for the read replica instances."
  type        = string
  default     = ""
}

variable "read_replica_activation_policy" {
  description = "The activation policy for the read replica instances. Can be either `ALWAYS`, `NEVER` or `ON_DEMAND`."
  type        = string
  default     = "ALWAYS"
}

variable "read_replica_crash_safe_replication" {
  description = "The crash safe replication is to indicates when crash-safe replication flags are enabled."
  type        = bool
  default     = true
}

variable "read_replica_disk_autoresize" {
  description = "Configuration to increase storage size."
  type        = bool
  default     = true
}

variable "read_replica_disk_size" {
  description = "The disk size for the read replica instances."
  type        = number
  default     = 10
}

variable "read_replica_disk_type" {
  description = "The disk type for the read replica instances."
  type        = string
  default     = "PD_SSD"
}

variable "read_replica_pricing_plan" {
  description = "The pricing plan for the read replica instances."
  type        = string
  default     = "PER_USE"
}

variable "read_replica_replication_type" {
  description = "The replication type for read replica instances. Can be one of ASYNCHRONOUS or SYNCHRONOUS."
  type        = string
  default     = "SYNCHRONOUS"
}

variable "read_replica_database_flags" {
  description = "The database flags for the read replica instances. See [more details](https://cloud.google.com/sql/docs/mysql/flags)"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "read_replica_maintenance_window_day" {
  description = "The day of week (1-7) for the read replica instances maintenance."
  type        = number
  default     = 1
}

variable "read_replica_maintenance_window_hour" {
  description = "The hour of day (0-23) maintenance window for the read replica instances maintenance."
  type        = number
  default     = 23
}

variable "read_replica_maintenance_window_update_track" {
  description = "The update track of maintenance window for the read replica instances maintenance. Can be either `canary` or `stable`."
  type        = string
  default     = "canary"
}

variable "read_replica_user_labels" {
  type        = map(string)
  default     = {}
  description = "The key/value labels for the read replica instances."
}

variable "read_replica_ip_configuration" {
  description = "The ip configuration for the read replica instances."
  type = object({
    authorized_networks = list(map(string))
    ipv4_enabled        = bool
    private_network     = string
    require_ssl         = bool
  })
  default = {
    authorized_networks = []
    ipv4_enabled        = true
    private_network     = null
    require_ssl         = null
  }
}

variable "create_timeout" {
  description = "The optional timout that is applied to limit long database creates."
  type        = string
  default     = "10m"
}

variable "update_timeout" {
  description = "The optional timout that is applied to limit long database updates."
  type        = string
  default     = "10m"
}

variable "delete_timeout" {
  description = "The optional timout that is applied to limit long database deletes."
  type        = string
  default     = "10m"
}

variable "additional_users" {
  description = "A list of users to be created in your cluster"
  type = list(object({
    project  = string
    name     = string
    password = string
    host     = string
    instance = string
  }))
  default = []
}



variable "additional_databases" {
  description = "A list of databases to be created in your cluster"
  type = list(object({
    project   = string
    name      = string
    charset   = string
    collation = string
    instance  = string
  }))
  default = []
}