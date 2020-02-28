
resource "google_bigquery_dataset" "reports" {
  dataset_id                  = "reports"
  description                 = "Materialized reports"
  location                    = "EU"
}

resource "google_bigquery_table" "current_totals" {
  dataset_id = google_bigquery_dataset.reports.dataset_id
  table_id   = "current_totals"
  schema = "${file("${path.module}/schemas/report.schema.json")}"
}

resource "google_bigquery_table" "historical_totals" {
  dataset_id = google_bigquery_dataset.reports.dataset_id
  table_id   = "historical_totals"
  schema = "${file("${path.module}/schemas/report.schema.json")}"
  time_partitioning {
    field = "day"
    type = "DAY"
    require_partition_filter = true
  }
}
