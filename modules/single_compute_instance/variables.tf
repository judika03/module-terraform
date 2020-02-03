####################
# network_interface
####################
variable "network" {
  description = "The name or self_link of the network to attach this interface to. Use network attribute for Legacy or Auto subnetted networks and subnetwork for custom subnetted networks."
  default     = ""
}

variable "subnetwork" {
  description = "The name of the subnetwork to attach this interface to. The subnetwork must exist in the same region this instance will be created in. Either network or subnetwork must be provided."
  default     = ""
}

variable "network_ip" {
  default     = ""
}

variable "subnetwork_project" {
  description = "The ID of the project in which the subnetwork belongs. If it is not provided, the provider project is used."
  default     = ""
}



variable "name-firewall" {
  default = "" 
}


variable "tags" {
  default = "" 
}

variable "zone" {
  default = "" 
}
variable "name" {
    default=""
}

variable "email" {
    default=""
}

variable "project_id" {
  type        = string
  description = "The GCP project ID"
  default     = null
}


variable "project_name" {
  description = "The GCP project to use for integration tests"
  default        = "spid-non-prod"
}

variable "region" {
  description = "The GCP region to create and test resources in"
  type        = string
  default     = "asia-southeast1"
}
variable "machine_type" {
  description = "Machine type to create, e.g. n1-standard-1"
  default     = ""
}
variable "startup_script" {
  description = "User startup script to run when instances spin up"
  default     = ""
}

variable "service_account" {
  description = "The GCP project to use for integration tests"
    default     = ""
}

variable "ports" {
}

variable "source_ranges" {
  
}

variable "instances_list" {
  description= "list instance"
  type=map
  default = {
   startup=""
   ipName=""

  }
  
}
