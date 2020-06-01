
locals {
  project           = "larkworthy-tester"
  project_number    = "455826092000"
  location          = "EU"
  region            = "europe-west1"
  base_image_name   = "openresty/openresty"
  base_image_tag    = "1.15.8.3-alpine"
  upstream_url      = "https://camunda-secure-flxotk3pnq-ew.a.run.app"
  authorized_domain = "futurice.com"
  # You need to provision this manually at https://console.developers.google.com/apis/credentials
  # We are building a Web Application and do not need the client_secret
  oauth_client_id = "455826092000-oi4h9ul0b943oi8f8in89pnjiroj1d4u.apps.googleusercontent.com"
  # Chicken and egg: You can only figure this out after deploying once!
  service_url = "https://openresty-flxotk3pnq-ew.a.run.app"
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

# Create service account to run service
resource "google_service_account" "openresty" {
  account_id   = "openresty"
  display_name = "openresty"
}

resource "google_project_iam_member" "openresty_invoker" {
  project = local.project
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.openresty.email}"
}

resource "google_project_iam_member" "openresty_publisher" {
  project = local.project
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.openresty.email}"
}
resource "google_project_iam_member" "openresty_subscriber" {
  project = local.project
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.openresty.email}"
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
  content = templatefile("${path.module}/files/default.template.conf", {
    OAUTH_CLIENT_ID      = local.oauth_client_id
    UPSTREAM_URL         = local.upstream_url
    AUTHORIZED_DOMAIN    = local.authorized_domain
    WAL_TOPIC            = google_pubsub_topic.httpwal.id
    SLACK_SIGNING_SECRET = "projects/455826092000/secrets/SlackSigningSecret/versions/latest"
    AUTHORIZED_WAL_USER  = google_service_account.openresty.email
  })
  filename = "${path.module}/.build/default.conf"
}

# Hydrate login into .build directory
resource "local_file" "login" {
  content = templatefile("${path.module}/files/login.template", {
    OAUTH_CLIENT_ID = local.oauth_client_id
  })
  filename = "${path.module}/.build/login"
}

# Copy files into .build directory
resource "template_dir" "swiss" {
  source_dir      = "${path.module}/files/swiss"
  destination_dir = "${path.module}/.build/swiss"
}

# Create a zip just to generate a sha
data "archive_file" "swiss" {
  type        = "zip"
  source_dir = "${path.module}/.build/swiss"
  output_path = "/tmp/swiss.zip"
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

resource "google_pubsub_topic" "httpwal" {
  name = "openresty_wal"
}

# grant Cloud Pub/Sub the permission to create tokens for authenticating the subscription
resource "google_project_iam_member" "pubsub_token_creator" {
  project = local.project
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:service-${local.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_pubsub_subscription" "httpwal" {
  name  = "httpwal"
  topic = google_pubsub_topic.httpwal.name

  ack_deadline_seconds = 120
  push_config {
    push_endpoint = "${local.service_url}/wal-playback/"

    oidc_token {
      service_account_email = google_service_account.openresty.email
    }
    attributes = {
      x-goog-version = "v1"
    }
  }
}
