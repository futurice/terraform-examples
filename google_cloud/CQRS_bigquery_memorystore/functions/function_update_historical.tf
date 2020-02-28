resource "google_cloudfunctions_function" "update_historical" {
  name    = "update_historical"
  runtime = "nodejs10"
  /* Running BQ client has minimal resource requirements */
  max_instances       = 1
  available_memory_mb = 128
  timeout             = 30
  entry_point         = "materialize"
  region              = var.config.region

  source_archive_bucket = var.config.code_bucket.name
  // Note we reuse source code setup in function_update_current.tf
  source_archive_object = google_storage_bucket_object.materialize_code.name

  // Function triggered by mutations in the upload bucket
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.version_every_hour.name
    failure_policy {
      retry = false
    }
  }

  environment_variables = {
    PROJECT        = var.config.project
    DATASET        = var.historical_totals_table.dataset_id
    TABLE          = var.historical_totals_table.table_id
    SOURCE_DATASET = var.historical_totals_latest_table.dataset_id
    SOURCE_TABLE   = var.historical_totals_latest_table.table_id
    N_DAYS         = var.config.retention_days
    BUCKET         = google_storage_bucket.memorystore_uploads.name
    FILE           = "historical_totals.json"
  }
}
