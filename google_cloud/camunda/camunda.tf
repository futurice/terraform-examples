# Copy Camunda base image from Dockerhub image into GCR
module "docker-mirror-camunda-bpm-platform" {
  source      = "github.com/neomantra/terraform-docker-mirror"
  image_name  = "camunda/camunda-bpm-platform"
  image_tag   = "7.12.0"
  dest_prefix = "eu.gcr.io/${local.project}"
}

# Build a customized version of Camunda to include the cloud sql postgres socket factory library
# Required to connect to Cloud SQL
resource "null_resource" "camunda_cloudsql" {
  triggers = {
    dockerfile = "${sha1(file("${path.module}/Dockerfile"))}"
  }
  provisioner "local-exec" {
    command = "gcloud builds submit --tag eu.gcr.io/${local.project}/camunda_cloudsql:3" # TODO pass tags through
  }
}

# Turn off auth
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers"
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.camunda.location
  project     = google_cloud_run_service.camunda.project
  service     = google_cloud_run_service.camunda.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_service_account" "camunda" {
  account_id   = "camunda-worker"
  display_name = "Camunda Worker"
}

resource "google_project_iam_member" "project" {
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.camunda.email}"
}

# Cloud Run Camunda service
resource "google_cloud_run_service" "camunda" {
  name     = "camunda"
  location = local.config.region
  depends_on = [null_resource.camunda_cloudsql]
  template {
    spec {
      # Lock down privileges
      service_account_name = google_service_account.camunda.email
      containers {
        image = "eu.gcr.io/${local.project}/camunda_cloudsql:3" # TODO pass tags through
        resources {
            limits = {
                # Default of 256Mb is not enough to start Camunda 
                memory = "2Gi"
            }
        }
        env {
          name  = "DB_URL"
          # See https://github.com/GoogleCloudPlatform/cloud-sql-jdbc-socket-factory
          # this is for app engine
          value = "jdbc:postgresql:///camunda?cloudSqlInstance=${google_sql_database_instance.camunda-db.connection_name}&socketFactory=com.google.cloud.sql.postgres.SocketFactory&user=camunda&password=futurice"
        }

        env {
          name  = "DB_DRIVER"
          value = "org.postgresql.Driver"
        }
        env {
          name  = "DB_USERNAME"
          value = "camunda"
        }
        env {
          name  = "DB_PASSWORD"
          value = "futurice"
        }
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
          value = "1"
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
