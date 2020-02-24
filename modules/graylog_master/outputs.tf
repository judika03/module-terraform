output "master_self_links" {
  description = "List of self-links for compute instances"
  value       = google_compute_address.graylog-spid-master.*.address
}