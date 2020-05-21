
# Policy to allow public access to Cloud Run endpoint
data "google_iam_policy" "noauth" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

# Bind public policy to our Camunda Cloud Run service
resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.camunda.location
  project     = google_cloud_run_service.camunda.project
  service     = google_cloud_run_service.camunda.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

# Create service account to run service
resource "google_service_account" "camunda" {
  account_id   = "camunda-worker"
  display_name = "Camunda Worker"
}

# Give the service account access to Cloud SQL
resource "google_project_iam_member" "project" {
  role   = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.camunda.email}"
}

# Cloud Run Camunda service
resource "google_cloud_run_service" "camunda" {
  name     = "camunda"
  location = local.config.region
  template {
    spec {
      # Use locked down Service Account
      service_account_name = google_service_account.camunda.email
      containers {
        image = null_resource.camunda_cloudsql_image.triggers.image
        resources {
          limits = {
            # Default of 256Mb is not enough to start Camunda 
            memory = "2Gi"
            cpu    = "1000m"
          }
        }
        env {
          name = "DB_URL"
          # Complicated DB URL to Cloud SQL
          # See https://github.com/GoogleCloudPlatform/cloud-sql-jdbc-socket-factory
          value = "jdbc:postgresql:///${google_sql_database.database.name}?cloudSqlInstance=${google_sql_database_instance.camunda-db.connection_name}&socketFactory=com.google.cloud.sql.postgres.SocketFactory"
        }

        env {
          name  = "DB_DRIVER"
          value = "org.postgresql.Driver"
        }
        env {
          name  = "DB_USERNAME"
          value = google_sql_user.user.name
        }
        env {
          name  = "DB_PASSWORD"
          value = google_sql_user.user.password
        }
        # Test instance of Cloud SQL has low connection limit
        # So we turn down the connection pool size
        env {
          name  = "DB_CONN_MAXACTIVE"
          value = "5"
        }
        env {
          name  = "DB_CONN_MAXIDLE"
          value = "5"
        }
        env {
          name  = "DB_CONN_MINIDLE"
          value = "0"
        }
        env {
          name  = "DB_VALIDATE_ON_BORROW"
          value = "true"
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "1" # no clusting
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.camunda-db.connection_name
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
