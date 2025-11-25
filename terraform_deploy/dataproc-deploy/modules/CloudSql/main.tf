# # Required APIs
# resource "google_project_service" "sqladmin" {
#   project = var.project_id
#   service = "sqladmin.googleapis.com"
# }
#
# resource "google_project_service" "servicenetworking" {
#   project = var.project_id
#   service = "servicenetworking.googleapis.com"
# }
#
# # Reserve an internal range for Private Service Access (PSA)
# resource "google_compute_global_address" "private_service_range" {
#   name          = "${var.prefix}-sql-psa"
#   project       = var.project_id
#   purpose       = "VPC_PEERING"
#   address_type  = "INTERNAL"
#   prefix_length = var.psa_prefix_length
#   network       = var.network_self_link
#
#   depends_on = [google_project_service.servicenetworking]
# }
#
# # Establish VPC peering for private IP Cloud SQL
# resource "google_service_networking_connection" "private_vpc_connection" {
#   network                 = var.network_self_link
#   service                 = "servicenetworking.googleapis.com"
#   reserved_peering_ranges = [google_compute_global_address.private_service_range.name]
# }
#
# # Cloud SQL instance (private IP only)
# resource "google_sql_database_instance" "this" {
#   name                = "${var.prefix}-pg"
#   project             = var.project_id
#   region              = var.region
#   database_version    = var.database_version
#   deletion_protection = var.deletion_protection
#
#   settings {
#     tier              = var.machine_type
#     availability_type = var.availability_type
#     disk_size         = var.disk_size_gb
#     disk_type         = var.disk_type
#
#     ip_configuration {
#       ipv4_enabled    = false
#       private_network = var.network_self_link
#       require_ssl     = false
#     }
#
#     backup_configuration {
#       enabled                       = true
#       point_in_time_recovery_enabled = true
#     }
#
#     maintenance_window {
#       day  = 7  # Sunday
#       hour = 3  # 03:00 regional time
#     }
#
#     insights_config {
#       query_insights_enabled   = true
#       query_string_length      = 1024
#       record_application_tags  = true
#       record_client_address    = true
#     }
#   }
#
#   depends_on = [google_service_networking_connection.private_vpc_connection]
# }
#
# # Initial DB + user (optional bootstrap)
# resource "google_sql_database" "db" {
#   name     = "my_db"
#   project  = var.project_id
#   instance = google_sql_database_instance.this.name
# }
#
# resource "google_sql_user" "user" {
#   name     = "admin"
#   project  = var.project_id
#   instance = google_sql_database_instance.this.name
#   password = "admin"
# }

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "instance" {
  name             = "dmeo-instance"
  region           = "us-central1"
  database_version = "MYSQL_8_0"
  deletion_protection  = true   #CHANGE THIS
  project = var.project_id

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_self_link
#      enable_private_path_for_google_cloud_services = true
    }

  }
}

#Creating the Database inside the Instance
resource "google_sql_database" "database" {
  name     = "my_db"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "users" {
  name     = "USERNAME"   #CHANGE THIS
  instance = google_sql_database_instance.instance.name
  password = "PASSWORD"   #CHANGE THIS
}