resource "google_bigquery_dataset" "ingress" {
  dataset_id                  = "ingress"
  description                 = "Raw event data"
  location                    = "EU"
}

resource "google_bigquery_table" "vendor1_ingress" {
  dataset_id = google_bigquery_dataset.ingress.dataset_id
  table_id   = "vendor1_ingress"
  schema = file("${path.module}/schemas/vendor1.schema.json")
  time_partitioning {
    field = "timestamp"
    type = "DAY"
    require_partition_filter = true
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_bigquery_table" "prober_ingress" {
  dataset_id = google_bigquery_dataset.ingress.dataset_id
  table_id   = "prober_ingress"
  schema = "${file("${path.module}/schemas/prober.schema.json")}"
  time_partitioning {
    field = "timestamp"
    type = "DAY"
    require_partition_filter = true
  }
  lifecycle {
    prevent_destroy = true
  }
}

