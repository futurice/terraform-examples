resource "google_bigquery_dataset" "urdfs" {
  dataset_id                  = "urdfs"
  description                 = "Data processing"
  location                    = "EU"
}
resource "google_storage_bucket_object" "jsonpath" {
  name   = "udf/jsonpath-0.8.0.js"
  source = "${path.module}/udf/jsonpath-0.8.0.js"
  bucket = "${var.config.code_bucket.name}"
}

resource "null_resource" "CUSTOM_JSON_EXTRACT_ARRAY_FLOAT" {
  triggers = {
    version = "0.0.4" // Bump to force apply to this resource
  }
  provisioner "local-exec" {
    command = "bq query --project=${var.config.project} --use_legacy_sql=false '${templatefile("${path.module}/udf/CUSTOM_JSON_EXTRACT_ARRAY_FLOAT.sql", {
        dataset = google_bigquery_dataset.urdfs.dataset_id
        library = "gs://${var.config.code_bucket.name}/${google_storage_bucket_object.jsonpath.output_name}"
    })}'"
  }
}
