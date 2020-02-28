locals {
  probe_function_name = "probe"
}

resource "google_cloudfunctions_function" "prober" {
  name    = "prober"
  runtime = "nodejs10"
  /* Probing has minimal resource requirements */
  max_instances       = 1
  available_memory_mb = 128
  timeout             = 30
  entry_point         = "probe"
  region              = var.config.region

  source_archive_bucket = var.config.code_bucket.name
  source_archive_object = google_storage_bucket_object.probe_code.name

  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.version_every_minute.name
    failure_policy {
      retry = false
    }
  }

  environment_variables = {
    PROBE_DATASET   = var.prober_ingress_table.dataset_id
    PROBE_TABLE     = var.prober_ingress_table.table_id
    CONTROLS_DATASET = var.control_dataset.dataset_id
  }
}

data "archive_file" "probe_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/probe"
  output_path = ".tmp/${local.probe_function_name}.zip"
}

resource "google_storage_bucket_object" "probe_code" {
  /* Name needs to be mangled to enable functions to be updated */
  name   = "${local.probe_function_name}.${data.archive_file.probe_zip.output_md5}.zip"
  bucket = var.config.code_bucket.name
  source = data.archive_file.probe_zip.output_path
}
