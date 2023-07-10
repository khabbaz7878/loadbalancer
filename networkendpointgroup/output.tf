output "neg_name_north_america" {
    value = google_compute_region_network_endpoint_group.neg["northamerica-northeast1"].name
}
output "neg_name_us_central" {
  value = google_compute_region_network_endpoint_group.neg["us-central1"].name
}
output "neg_id_north_america" {
    value = google_compute_region_network_endpoint_group.neg["us-central1"].id
}
output "neg_id_us_central" {
    value = google_compute_region_network_endpoint_group.neg["northamerica-northeast1"].id
}
output "neg_self_link_us_central" {
  value = google_compute_region_network_endpoint_group.neg["us-central1"].self_link
}
output "neg_self_link_north_america" {
  value = google_compute_region_network_endpoint_group.neg["northamerica-northeast1"].self_link
}