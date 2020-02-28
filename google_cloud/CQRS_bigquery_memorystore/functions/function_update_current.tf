locals {
  materializer_function_name = "materialize"
}

resource "google_cloudfunctions_function" "update_current" {
  name    = "update_current"
  runtime = "nodejs10"
  /* Running BQ client has minimal resource requirements */
  max_instances       = 1
  available_memory_mb = 128
  timeout             = 30
  entry_point         = "materialize"
  region              = var.config.region

  source_archive_bucket = var.config.code_bucket.name
  source_archive_object = google_storage_bucket_object.materialize_code.name

  // Function triggered by mutations in the upload bucket
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.version_every_two_minutes.name
    failure_policy {
      retry = false
    }
  }

  environment_variables = {
    PROJECT        = var.config.project
    DATASET        = var.current_totals_table.dataset_id
    TABLE          = var.current_totals_table.table_id
    SOURCE_DATASET = var.current_totals_latest_table.dataset_id
    SOURCE_TABLE   = var.current_totals_latest_table.table_id
    BUCKET         = google_storage_bucket.memorystore_uploads.name
    FILE           = "current_totals.json"
  }
}

data "archive_file" "materialize_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/materialize"
  output_path = ".tmp/${local.materializer_function_name}.zip"
}

resource "google_storage_bucket_object" "materialize_code" {
  /* Name needs to be mangled to enable functions to be updated */
  name   = "${local.materializer_function_name}.${data.archive_file.materialize_zip.output_md5}.zip"
  bucket = var.config.code_bucket.name
  source = data.archive_file.materialize_zip.output_path
}
