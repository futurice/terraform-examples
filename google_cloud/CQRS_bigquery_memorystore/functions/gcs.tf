resource "google_storage_bucket" "memorystore_uploads" {
  name     = "${var.config.project}_memorystore_uploads"
  location = "${var.config.region}"
}
