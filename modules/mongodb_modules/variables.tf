
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

variable "additional_shards" {
    default = 0
}

variable "ubuntu_mongo_image" {
    description = "VM image which have to consist of mongoDB and ubuntu"
}

variable "database_name" {
    description = "the name of the database"
}


variable "collection_name" {
    description = "the name of the collections"
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

variable "shard_key" {
    description  = "the shard key of the database"
}

variable "index_type" {
    description = "index type of the database"
}


variable "ports" {
  description =  "list of ports to be enabled by the firewall"
}

variable "source_ranges" {
  
}