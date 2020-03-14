terraform {
  backend "gcs" {
    prefix = "terraform/state"
    bucket = "terraform-larkworthy-camunda" // Must be pre-provisioned
  }
}

provider "google" {
  project = "larkworthy-tester"
  region  = "europe-west1"
}

locals {
  project = "larkworthy-tester"
  config = {
    project         = local.project
    base_image_name = "camunda/camunda-bpm-platform"
    base_image_tag  = "7.12.0"
    region          = "europe-west1"
  }
}
