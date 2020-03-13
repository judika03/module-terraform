
variable "startup-script" {
    description = "startup-script"
    default = ""
}

variable "network" {
    description = "network of the instance"
}

variable "instance_count" {
    default = null
}

variable "number_of_shards" {
    default = 0
}

variable "ubuntu_mongo_image" {
    description = "VM image which have to consist of mongoDB and ubuntu"
}


variable "machine_type" {
    description = "the machine type of the VM on which the router and shards are running"
}

variable "config_port" {}

variable "shard_port" {
    description = "default port for the shards inside the database"
}

variable "router_port" {
    description = "default port for router inside the database"
  
}

variable "ports" {
  description =  "list of ports to be enabled by the firewall"
}

variable "source_ranges" {
  
}

variable "shard_name" {}

variable "router_name" {}

variable "number_of_backup" {
    description = "the number of backup for  each  shard"
}


variable "username" {
    description = "username used to log-in"
}
variable "password" {
    description = "password used to log-in"
}