output "neg_name_north_america" {
    value = google_compute_region_network_endpoint_group.neg["northamerica-northeast1"]
}
output "neg_name_us_central" {
  value = google_compute_region_network_endpoint_group.neg["us-central1"]
}
output "neg_id_north_america" {
    value = google_compute_region_network_endpoint_group.neg["us-central1"]
}
output "neg_id_us_central" {
    value = google_compute_region_network_endpoint_group.neg["northamerica-northeast1"]
}