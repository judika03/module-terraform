

variable "project_id" {
  description = "The GCP project to use for integration tests"
  default        = "spid-non-prod"
}

variable "region" {
  description = "The GCP region to create and test resources in"
  type        = string
  default     = "asia-southeast1"
}

variable "zone" {
  description = "The GCP region to create and test resources in"
  type        = string
  default     = "asia-southeast1-a"
}


variable "subnetwork" {
  description = "The subnetwork to host the compute instances in"
  default     = "default"
}

variable "num_instances" {
  description = "Number of instances to create"
  default="1"
}

variable "service_account" {
  description = "The GCP project to use for integration tests"
  default        = "redis-server"
}

variable "prefix" {
  type        = string
  description = "Prefix applied to service account names."
  default     = "aku"
}



variable "cluster_name" {
  description = "Name of the elasticsearch cluster, used in node discovery"
  default     = "elasticsearch"
}

variable "zones" {
  type    = "list"
  default = ["asia-southeast1-a", "asia-southeast1-b", "asia-southeast1-c"]
}


variable "master_node" {
  description = "Node functions as master node"
  default     = true
}

variable "data_node" {
  description = "Node functions as data node"
  default     = false
}

variable "heap_size" {
  description = "Heap size, should be half of the node memory up to 31g"
  default     = "4g"
}
variable "minimum_master_nodes" {
  description = "Minimum master node"
  default     = 2
}

variable "master_node1" {
  description = "Node functions as master node"
  default     = false
}
variable "data_node1" {
  description = "Node functions as data node"
  default     = true
}

variable "master_machine_type" {
  default = "n1-standard-2"
}