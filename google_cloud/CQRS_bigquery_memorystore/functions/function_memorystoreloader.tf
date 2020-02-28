locals {
  memorystoreloader_function_name = "memorystoreload"
}

resource "google_cloudfunctions_function" "memorystoreloader" {
  name    = "memorystoreloader"
  runtime = "nodejs10"
  /* Testing has minimal resource requirements */
  max_instances       = 2
  available_memory_mb = 2048 // Cache loading speed is improved with better instance type, linearly
  timeout             = 60
  entry_point         = "memorystoreload"
  region              = var.config.region

  source_archive_bucket = var.config.code_bucket.name
  source_archive_object = google_storage_bucket_object.memorystoreload_code.name

  // Function triggered by mutations in the upload bucket
  event_trigger {
    event_type = "providers/cloud.storage/eventTypes/object.change"
    resource   = google_storage_bucket.memorystore_uploads.name
    failure_policy {
      retry = false
    }
  }

  provider      = "google-beta"
  vpc_connector = google_vpc_access_connector.serverless_vpc_connector.name

  environment_variables = {
    REDIS_HOST = var.memorystore_host
    REDIS_PORT = 6379
    EXPIRY     = 60 * 60 * 24 * 30 // 30d expiry for keys
  }
}

data "archive_file" "memorystoreload_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/memorystoreload"
  output_path = ".tmp/${local.memorystoreloader_function_name}.zip"
}

resource "google_storage_bucket_object" "memorystoreload_code" {
  /* Name needs to be mangled to enable functions to be updated */
  name   = "${local.memorystoreloader_function_name}.${data.archive_file.memorystoreload_zip.output_md5}.zip"
  bucket = var.config.code_bucket.name
  source = data.archive_file.memorystoreload_zip.output_path
}
