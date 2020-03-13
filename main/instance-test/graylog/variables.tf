

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

variable "network" {
  description = "The subnetwork to host the compute instances in"
  default     = "default"
}

variable "subnetwork" {
  description = "The subnetwork to host the compute instances in"
  default     = "default"
}

variable "subnetwork_project" {
  description = "The subnetwork to host the compute instances in"
  default     = "spid-non-prod"
}

variable "instance_group" {
  description = "Instance group for LB"
  default = ""
  type = string 
}