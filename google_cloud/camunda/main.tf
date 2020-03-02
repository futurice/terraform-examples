terraform {
  backend "gcs" {
    prefix  = "terraform/state"
    bucket  = "terraform-larkworthy-camunda" // Must be pre-provisioned
  }
}

provider "google" {
  project     = "larkworthy-tester"
  region      = "europe-west1"
}

provider "google-beta" {
  project     = "larkworthy-tester"
  region      = "europe-west1"
}

provider "docker" {

  # Blank Host us DOCKER_HOST instead
  # host = "tcp://127.0.0.1:2376/" 
}

provider "archive" {
  version = "~> 1.2.0"
}

locals {
  project = "larkworthy-tester"
  config = {
    project = local.project
    region = "europe-west1"
    version = module.version.result
    code_bucket = google_storage_bucket.code
  }
}

// We generate a version of the backend by hashing the contents of this directory
module "version" {
  source = "github.com/claranet/terraform-path-hash?ref=v0.1.0"
  path   = "."
}

resource "google_storage_bucket" "code" {
  name     = "${local.project}_camunda_code"
  location = "EU"
}
