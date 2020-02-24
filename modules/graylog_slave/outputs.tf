output "instances_self_links" {
  description = "List of self-links for compute instances"
  value       = google_compute_address.graylog-spid.*.address
}

output "instance_group_url" {
  description = "Instance group for Load Balancer"
  value = google_compute_instance_group.graylog-ig.self_link
}