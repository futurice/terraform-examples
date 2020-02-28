output "prober_ingress_table" {
  value = google_bigquery_table.prober_ingress
}

output "control_dataset" {
  value = google_bigquery_dataset.ingress
}
output "unified_values_table" {
  value = google_bigquery_table.unified_values
}
output "current_totals_latest_table" {
  value = google_bigquery_table.current_totals_latest
}

output "historical_totals_latest_table" {
  value = google_bigquery_table.historical_totals_latest
}

output "current_totals_table" {
  value = google_bigquery_table.current_totals
}

output "historical_totals_table" {
  value = google_bigquery_table.historical_totals
}

output "ingress_dataset" {
  value = google_bigquery_dataset.ingress
}
