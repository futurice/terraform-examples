resource "google_cloud_scheduler_job" "version_every_minute" {
  name        = "version_every_minute"
  description = "Pings topic with version once a min"
  schedule    = "* * * * *"
  project     = var.config.project
  region      = var.config.region

  pubsub_target {
    topic_name = "${google_pubsub_topic.version_every_minute.id}"
    data = "${base64encode(jsonencode({
      version = "${var.config.version}"
    }))}"
  }
}

resource "google_cloud_scheduler_job" "version_every_two_minutes" {
  name        = "version_every_two_minutes"
  description = "Pings topic with version once every 2 mins"
  schedule    = "*/2 * * * *"
  project     = "${var.config.project}"
  region      = "${var.config.region}"

  pubsub_target {
    topic_name = "${google_pubsub_topic.version_every_two_minutes.id}"
    data = "${base64encode(jsonencode({
      version = "${var.config.version}"
    }))}"
  }
}

resource "google_cloud_scheduler_job" "version_every_hour" {
  name        = "version_every_hour"
  description = "Pings topic with version once every hour"
  schedule    = "0 * * * *"
  region      = "${var.config.region}"
  project     = "${var.config.project}"

  pubsub_target {
    topic_name = "${google_pubsub_topic.version_every_hour.id}"
    data = "${base64encode(jsonencode({
      version = "${var.config.version}"
    }))}"
  }
}
