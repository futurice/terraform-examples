
locals {
  project         = "larkworthy-tester"
  location        = "EU"
  region          = "europe-west1"
  base_image_name = "openresty/openresty"
  base_image_tag  = "1.15.8.3-alpine-nosse42"
}

terraform {
  backend "gcs" {
    prefix = "openresty/state"
    bucket = "terraform-larkworthy"
  }
}

provider "google" {
  project = local.project
  region  = local.region
}

# Create service account to run service with no permissions
resource "google_service_account" "openresty" {
  account_id   = "openresty"
  display_name = "openresty"
}

# Policy to allow public access to Cloud Run endpoint
data "google_iam_policy" "noauth" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

# Allow public access to ORY openresty
resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.openresty.location
  project     = google_cloud_run_service.openresty.project
  service     = google_cloud_run_service.openresty.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

# Hydrate config into .build directory
resource "local_file" "config" {
  content = templatefile("${path.module}/default.template.conf", {
    // camunda_url = "https://camunda-flxotk3pnq-ew.a.run.app"
    camunda_url = "https://camunda-secure-flxotk3pnq-ew.a.run.app"
  })
  filename = "${path.module}/.build/default.conf"
}

# Cloud Run Openresty
resource "google_cloud_run_service" "openresty" {
  name     = "openresty"
  location = local.region
  template {
    spec {
      # Use locked down Service Account
      service_account_name = google_service_account.openresty.email
      containers {
        image = null_resource.openresty_image.triggers.image
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
