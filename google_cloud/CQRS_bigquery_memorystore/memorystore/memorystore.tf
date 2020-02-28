resource "google_redis_instance" "cache" {
  name                    = "redis"
  memory_size_gb          = 1
  project                 = var.config.project
  location_id             = "${var.config.region}-c"
  tier                    = "BASIC"
  authorized_network      = var.config.network
}
