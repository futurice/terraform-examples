resource "google_pubsub_topic" "version_every_minute" {
  name = "version_every_minute"
}

resource "google_pubsub_topic" "version_every_two_minutes" {
  name = "version_every_two_minutes"
}

resource "google_pubsub_topic" "version_every_hour" {
  name = "version_every_hour"
}
