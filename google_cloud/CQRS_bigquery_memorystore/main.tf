terraform {
  backend "gcs" {
    prefix  = "terraform/state"
    bucket  = "terraform-larkworthy-tester" // Must be pre-provisioned
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

provider "archive" {
  version = "~> 1.2.0"
}

locals {
  project = "larkworthy-tester"
  config = {
    project = local.project
    region = "europe-west1"
    version = module.version.result
    retention_days = 30
    network = "default"
    ip_cidr_range = "10.9.0.0/28"    
    memorystore_tier = "BASIC"
    code_bucket = google_storage_bucket.code
  }
}

// We generate a version of the backend by hashing the contents of this directory
module "version" {
  source = "github.com/claranet/terraform-path-hash?ref=v0.1.0"
  path   = "."
}

resource "google_storage_bucket" "code" {
  name     = "${local.project}_code"
  location = "EU"
}

resource "google_storage_bucket_object" "config_file" {
  name   = "config.json"
  content = jsonencode(local.config)
  bucket = google_storage_bucket.code.name
}

module "bigquery" {
  source = "./bigquery"
  config = local.config
}

module "memorystore" {
  source = "./memorystore"
  config = "${local.config}"
}

module "functions" {
  source = "./functions"
  memorystore_host = module.memorystore.memorystore_host

  prober_ingress_table = module.bigquery.prober_ingress_table
  control_dataset = module.bigquery.control_dataset
  unified_values_table = module.bigquery.unified_values_table
  current_totals_latest_table = module.bigquery.current_totals_latest_table
  historical_totals_latest_table = module.bigquery.historical_totals_latest_table
  current_totals_table = module.bigquery.current_totals_table
  historical_totals_table = module.bigquery.historical_totals_table
  
  config = local.config
}

