

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

variable "subnetwork_project" {
  description = "The subnetwork to host the compute instances in"
  default     = "spid-non-prod"
}
variable "num_instances" {
  description = "Number of instances to create"
  default="1"
}

variable "prefix" {
  type        = string
  description = "Prefix applied to service account names."
  default     = "spid"
}




variable "cluster_name" {
  description = "Name of the elasticsearch cluster, used in node discovery"
  default     = "elasticsearch"
}

variable "zones" {
  type    = list
  default = ["asia-southeast1-a", "asia-southeast1-b", "asia-southeast1-c"]
}


