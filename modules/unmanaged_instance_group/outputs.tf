
output "self_links" {
  description = "List of self-links for unmanaged instance groups"
  value       = google_compute_instance_group.instance_group.*.self_link
}


output "available_zones" {
  description = "List of available zones in region"
  value       = data.google_compute_zones.available.names
}

