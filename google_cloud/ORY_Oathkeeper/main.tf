
locals {
  project         = "larkworthy-tester"
  location        = "EU"
  region          = "europe-west1"
  base_image_name = "oryd/oathkeeper"
  base_image_tag  = "v0.37.1"
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

# Mirror base image from Dockerhub image into Google Container Registry
module "docker-mirror" {
  source      = "github.com/neomantra/terraform-docker-mirror"
  image_name  = local.base_image_name
  image_tag   = local.base_image_tag
  dest_prefix = "eu.gcr.io/${local.project}"
}

# config bucket for service
resource "google_storage_bucket" "config" {
  name     = "${local.project}_${local.region}_oathkeeper"
  location = local.location
  bucket_policy_only = true
}

# config for service
resource "google_storage_bucket_object" "config" {
  name = "config.yml"
  content = templatefile(
    "${path.module}/config.template.yml", {
  })
  bucket = google_storage_bucket.config.name
}

# Let oathkeeper read objects from it
resource "google_storage_bucket_iam_member" "oathkeeper-viewer" {
  bucket = google_storage_bucket.config.name
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.oathkeeper.email}"
}

# Cloud Run ORY Oathkeeper
resource "google_cloud_run_service" "oathkeeper" {
  name     = "oathkeeper"
  location = local.region
  template {
    spec {
      # Use locked down Service Account
      service_account_name = google_service_account.oathkeeper.email
      containers {
        args  = ["--config", "https://storage.cloud.google.com/${google_storage_bucket.config.name}/${google_storage_bucket_object.config.name}"]
        image = module.docker-mirror.dest_full
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
