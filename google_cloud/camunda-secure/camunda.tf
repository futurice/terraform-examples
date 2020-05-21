# Create service account to run service
resource "google_service_account" "camunda" {
  account_id   = "camunda-secure-worker"
  display_name = "Camunda Secure Worker"
}

# Give the service account access to Cloud SQL
resource "google_project_iam_member" "project" {
  role   = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.camunda.email}"
}

# Cloud Run Camunda service
resource "google_cloud_run_service" "camunda" {
  name     = "camunda-secure"
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
            cpu    = "2000m"
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
          name  = "nonce"
          value = "ddd"
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
          value = "0"
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
