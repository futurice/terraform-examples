resource "google_sql_database_instance" "camunda-db" {
  name             = "camunda-db-postgres"
  database_version = "POSTGRES_11"
  region           = local.config.region

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
    ip_configuration {
        ipv4_enabled = true # Private IP not possible with Cloud Run
    }
  }
}

resource "google_sql_user" "user" {
  name     = "camunda"
  instance = google_sql_database_instance.camunda-db.name
  password = "futurice"
}

resource "google_sql_database" "database" {
  name     = "camunda"
  instance = google_sql_database_instance.camunda-db.name
}