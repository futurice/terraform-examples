
locals {
  control_fields = ["multiplier"]
  control_types  = ["FLOAT"]
  default_value  = ["1.0"]
}

resource "google_bigquery_table" "control_operations" {
  count = length(local.control_fields)
  dataset_id = google_bigquery_dataset.ingress.dataset_id
  table_id   = "control_${element(local.control_fields, count.index)}"
  schema = templatefile(
      "${path.module}/schemas/control.template.schema.json", {
          FIELD = element(local.control_fields, count.index)
          TYPE = element(local.control_types, count.index)
      })
  time_partitioning {
    field = "timestamp"
    type = "DAY"
    require_partition_filter = false
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_bigquery_table" "control_range_view" {
  count = length(local.control_fields)
  dataset_id = google_bigquery_dataset.views.dataset_id
  table_id   = "control_value_range_${element(local.control_fields, count.index)}"
  view {
    query = templatefile("${path.module}/sql/control_range_view.sql", {
          NAME = element(local.control_fields, count.index),
          DEFAULT = element(local.default_value, count.index)
          OPERATIONS = "${var.config.project}.${google_bigquery_table.control_operations[count.index].dataset_id}.${google_bigquery_table.control_operations[count.index].table_id}"
    })
    use_legacy_sql = false
  }
}