

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
  default="3"
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

variable "name" {
    default="judika"
}



