locals {
  ip_cidr_range = "10.0.1.0/24"
}

resource "google_compute_network" "custom_network" {
  name                    = "${var.prefix}-cluster-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "my_subnet" {
  depends_on               = [google_compute_network.custom_network]
  name                     = "${var.prefix}-subnetwork"
  ip_cidr_range            = local.ip_cidr_range
  region                   = var.region
  network                  = google_compute_network.custom_network.id
  private_ip_google_access = true
}

resource "google_compute_firewall" "firewall_rules" {
  depends_on = [google_compute_network.custom_network]
  name       = "${var.prefix}-dataproc-allow-tcp-udp-icmp-all-ports"
  network    = google_compute_network.custom_network.name

  // Allow ping
  allow {
    protocol = "icmp"
  }
  //Allow all TCP ports
  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }
  //Allow all UDP ports
  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }
  source_ranges = [local.ip_cidr_range]
}