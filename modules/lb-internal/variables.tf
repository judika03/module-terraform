variable "project" {
  description = "The project to deploy to, if not set the default provider project is used."
  default     = ""
}

variable "region" {
  description = "Region for cloud resources."
  default     = "us-central1"
}

variable "network" {
  description = "Name of the network to create resources in."
  default     = "default"
}

variable "subnetwork" {
  description = "Name of the subnetwork to create resources in."
  default     = "default"
}

variable "network_project" {
  description = "Name of the project for the network. Useful for shared VPC. Default is var.project."
  default     = ""
}

variable "name" {
  description = "Name for the forwarding rule and prefix for supporting resources."
}

variable "backends" {
  description = "List of backends, should be a map of key-value pairs for each backend, must have the 'group' key."
  type        = list(object({ group = string, description = string }))
}

variable "session_affinity" {
  description = "The session affinity for the backends example: NONE, CLIENT_IP. Default is `NONE`."
  default     = "NONE"
}

variable "ports" {
  description = "List of ports range to forward to backend services. Max is 5."
  type        = list(string)
}

variable "health_check" {
  description = "Health check to determine whether instances are responsive and able to do work"
  type = object({
    type                = string
    check_interval_sec  = number
    healthy_threshold   = number
    timeout_sec         = number
    unhealthy_threshold = number
    response            = string
    proxy_header        = string
    port                = number
    port_name           = string
    request             = string
    request_path        = string
    host                = string
  })
}

variable "source_tags" {
  description = "List of source tags for traffic between the internal load balancer."
  type        = list(string)
}

variable "target_tags" {
  description = "List of target tags for traffic between the internal load balancer."
  type        = list(string)
}

variable "source_ip_ranges" {
  description = "List of source ip ranges for traffic between the internal load balancer."
  type        = list(string)
  default     = null
}

variable "source_service_accounts" {
  description = "List of source service accounts for traffic between the internal load balancer."
  type        = list(string)
  default     = null
}

variable "target_service_accounts" {
  description = "List of target service accounts for traffic between the internal load balancer."
  type        = list(string)
  default     = null
}

variable "ip_address" {
  description = "IP address of the internal load balancer, if empty one will be assigned. Default is empty."
  default     = null
}

variable "ip_protocol" {
  description = "The IP protocol for the backend and frontend forwarding rule. TCP or UDP."
  default     = "TCP"
}

variable "service_label" {
  description = "Service label is used to create internal DNS name"
  default     = null
  type        = string
}
