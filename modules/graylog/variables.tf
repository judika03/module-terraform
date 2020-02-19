

variable "project_id" {
  description = "The GCP project to use for integration tests"
  default        = "spid-non-prod"
}

variable "region" {
  description = "The GCP region to create and test resources in"
  type        = string
  default     = "asia-southeast1"
}

variable "private_key" {
  default = "~/.ssh/MyKeyPair.pem"
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
variable "num_instances" {
  description = "Number of instances to create"
  default="1"
}
variable "machine_type" {

}

variable "tags" {
  description = "Number of instances to create"
  default="teser"
}

variable "ame-firewall" {
  description = "Number of instances to create"
  default="teser"
}


variable "ansible_user" {
  default = "judika.gultom"
}
