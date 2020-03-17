locals {
    test_function_name = "test"
}

resource "google_cloudfunctions_function" "test" {
  name                  = "test"
  runtime               = "nodejs10"
  /* Testing has minimal resource requirements */
  max_instances         = 1   
  available_memory_mb   = 128
  timeout               = 30
  entry_point           = "test"
  region                = var.config.region

  source_archive_bucket = var.config.code_bucket.name
  source_archive_object = google_storage_bucket_object.test_code.name

  trigger_http = true

  provider      = "google-beta"
  vpc_connector = google_vpc_access_connector.serverless_vpc_connector.name

  environment_variables = {
    CONFIG_BUCKET = var.config.code_bucket.name
    PROBER_DATASET = var.prober_ingress_table.dataset_id
    PROBER_TABLE = var.prober_ingress_table.table_id
    UNIFIED_VALUES_DATASET = var.unified_values_table.dataset_id
    UNIFIED_VALUES_TABLE = var.unified_values_table.table_id
    /*
    UNIFIED_METABOLICS_DATASET = var.unified_metabolics_table.dataset_id
    UNIFIED_METABOLICS_TABLE = var.unified_metabolics_table.table_id
    */
    CURRENT_TOTALS_DATASET = var.current_totals_table.dataset_id
    CURRENT_TOTALS_TABLE = var.current_totals_table.table_id
    /*
    DAILY_METABOLICS_PRECOMPUTE_DATASET = var.daily_metabolics_precompute_table.dataset_id
    DAILY_METABOLICS_PRECOMPUTE_TABLE = var.daily_metabolics_precompute_table.table_id
    */
    MEMORYSTORE_UPLOADS_BUCKET = google_storage_bucket.memorystore_uploads.name
    REDIS_HOST = var.memorystore_host
    REDIS_PORT = 6379
  }
}

data "archive_file" "test_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/test"
  output_path = ".tmp/${local.test_function_name}.zip"
}

resource "google_storage_bucket_object" "test_code" {
  /* Name needs to be mangled to enable functions to be updated */
  name   = "${local.test_function_name}.${data.archive_file.test_zip.output_md5}.zip"
  bucket = var.config.code_bucket.name
  source = data.archive_file.test_zip.output_path
}
