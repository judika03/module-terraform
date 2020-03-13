output "ip_address" {
  description = "The internal IP assigned to the regional forwarding rule."
  value       = google_compute_forwarding_rule.default.ip_address
}
