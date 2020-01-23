output "router_external_ip" {
    value = google_compute_address.external_router.address
}