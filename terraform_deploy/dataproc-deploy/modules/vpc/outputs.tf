output "subnet_id" {
  value = google_compute_subnetwork.my_subnet.id
}
output "vpc_id" {
  value = google_compute_network.custom_network.id
}
output "vpc_self_link" {
  value = google_compute_network.custom_network.self_link
}
