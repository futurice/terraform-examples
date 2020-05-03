
locals {
  project         = "larkworthy-tester"
  location        = "EU"
  region          = "europe-west1"
  base_image_name = "oryd/oathkeeper"
  base_image_tag  = "v0.37.1"
  #base_image_tag  = "v0.36.0-beta.4"
}

terraform {
  backend "gcs" {
    prefix = "ORY_Oathkeeper/state"
    bucket = "terraform-larkworthy"
  }
}

provider "google" {
  project = local.project
  region  = local.region
}

# Create service account to run service with no permissions
resource "google_service_account" "oathkeeper" {
  account_id   = "oathkeeper"
  display_name = "oathkeeper"
}

# Policy to allow public access to Cloud Run endpoint
data "google_iam_policy" "noauth" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

# Allow public access to ORY Oathkeeper
resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.oathkeeper.location
  project     = google_cloud_run_service.oathkeeper.project
  service     = google_cloud_run_service.oathkeeper.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

# config bucket for service
resource "google_storage_bucket" "config" {
  name               = "${local.project}_${local.region}_oathkeeper"
  location           = local.location
  bucket_policy_only = true
}

# rules for service
resource "google_storage_bucket_object" "rules" {
  name = "rules_${filesha256("${path.module}/rules.template.yml")}.yml"
  content = templatefile(
    "${path.module}/rules.template.yml", {
      // camunda_url = "https://camunda-flxotk3pnq-ew.a.run.app"
      camunda_url = "https://camunda-secure-flxotk3pnq-ew.a.run.app"
      # Note Cloud run terminates https so container exposed only to http
      oathkeeper_url = "http://oathkeeper-flxotk3pnq-ew.a.run.app"
  })
  bucket = google_storage_bucket.config.name
}

# Let oathkeeper read objects from it
resource "google_storage_bucket_iam_member" "oathkeeper-viewer" {
  bucket = google_storage_bucket.config.name
  role   = "roles/storage.objectViewer"
  # member = "serviceAccount:${google_service_account.oathkeeper.email}"
  member = "allUsers" # work around until we can use the cloud API https://github.com/ory/oathkeeper/issues/425
}

# Cloud Run ORY Oathkeeper
resource "google_cloud_run_service" "oathkeeper" {
  name     = "oathkeeper"
  location = local.region
  depends_on = [google_storage_bucket_object.rules]
  template {
    spec {
      # Use locked down Service Account
      service_account_name = google_service_account.oathkeeper.email
      containers {
        image = null_resource.oathkeeper_image.triggers.image
        args = ["--config", "/config.yaml"]
        env { 
          name  = "nonce"
          value = filesha256("${path.module}/rules.template.yml") # Force refresh on rule change
        }
        env {
          name  = "ACCESS_RULES_REPOSITORIES"
          # storage.cloud.google.com domain serves content via redirects which is does not work ATM https://github.com/ory/oathkeeper/issues/425
          value = "https://storage.googleapis.com/${google_storage_bucket.config.name}/${google_storage_bucket_object.rules.name}"
        }
        env {
          name  = "LOG_LEVEL"
          value = "debug"
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
