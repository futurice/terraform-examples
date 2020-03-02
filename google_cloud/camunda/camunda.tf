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

# Cloud Run Camunda service
resource "google_cloud_run_service" "camunda" {
  name     = "camunda"
  location = local.config.region
  depends_on = [null_resource.camunda_cloudsql]
  template {
    spec {
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
      }
    }

    metadata {
      annotations = {
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.camunda-db.connection_name
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
