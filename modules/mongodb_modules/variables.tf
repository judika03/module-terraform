
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
}

variable "database_name" {}


variable "collection_name" {}

variable "machine_type" {}

variable "config_port" {}

variable "shard_port" {}

variable "router_port" {
  
}


variable "ports" {
  
}

variable "source_ranges" {
  
}
