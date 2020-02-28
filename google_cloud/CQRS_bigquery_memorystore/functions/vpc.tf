resource "google_vpc_access_connector" "serverless_vpc_connector" {
  name          = "${var.config.network}-connector"
  provider      = "google-beta"
  region        = var.config.region
  ip_cidr_range = var.config.ip_cidr_range
  network       = var.config.network
}
