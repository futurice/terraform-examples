/*
Connect with friends via a shared digital space in Minecraft.

This is a safe Minecraft server that won't break the bank. Game data is preserved across sessions.
Server is hosted on a permenant IP address. You need to start the VM each session, but it
will shutdown within 24 hours if you forget to turn it off.
Process is run in a sandboxed VM, so any server exploits cannot do any serious damage.

We are experimenting with providing support through a [google doc](https://docs.google.com/document/d/1TXyzHKqoKMS-jY9FSMrYNLEGathqSG8YuHdj0Z9GP34).
Help us make this simple for others to use by asking for help.


Features
- Runs [itzg/minecraft-server](https://hub.docker.com/r/itzg/minecraft-server/) Docker image
- Preemtible VM (cheapest), shuts down automatically within 24h if you forget to stop the VM
- Reserves a stable public IP, so the minecraft clients do not need to be reconfigured
- Reserves the disk, so game data is remembered across sessions
- Restricted service account, VM has no ability to consume GCP resources beyond its instance and disk
- 2$ per month
  - Reserved IP address costs: $1.46 per month
  - Reserved 10Gb disk costs: $0.40
  - VM cost: $0.01 per hour, max session cost $0.24
*/

# We require a project to be provided upfront
# Create a project at https://cloud.google.com/
# Make note of the project ID
# We need a storage bucket created upfront too to store the terraform state
terraform {
  backend "gcs" {
    prefix = "minecraft/state"
    bucket = "terraform-larkworthy"
  }
}

# You need to fill these locals out with the project, region and zone
# Then to boot it up, run:-
#   gcloud auth application-default login
#   terraform init
#   terraform apply
locals {
  # The Google Cloud Project ID that will host and pay for your Minecraft server
  project = "larkworthy-tester"
  region  = "europe-west1"
  zone    = "europe-west1-b"
  # Allow members of an external Google group to turn on the server
  # through the Cloud Console mobile app or https://console.cloud.google.com
  # Create a group at https://groups.google.com/forum/#!creategroup
  # and invite members by their email address.
  enable_switch_access_group = 1
  minecraft_switch_access_group = "minecraft-switchers-lark@googlegroups.com"
}


provider "google" {
  project = local.project
  region  = local.region
}

# Create service account to run service with no permissions
resource "google_service_account" "minecraft" {
  account_id   = "minecraft"
  display_name = "minecraft"
}

# Permenant Minecraft disk, stays around when VM is off
resource "google_compute_disk" "minecraft" {
  name  = "minecraft"
  type  = "pd-standard"
  zone  = local.zone
  image = "cos-cloud/cos-stable"
}

# Permenant IP address, stays around when VM is off
resource "google_compute_address" "minecraft" {
  name   = "minecraft-ip"
  region = local.region
}

# VM to run Minecraft, we use preemptable which will shutdown within 24 hours
resource "google_compute_instance" "minecraft" {
  name         = "minecraft"
  machine_type = "n1-standard-1"
  zone         = local.zone
  tags         = ["minecraft"]

  # Run itzg/minecraft-server docker image on startup
  # The instructions of https://hub.docker.com/r/itzg/minecraft-server/ are applicable
  # For instance, Ssh into the instance and you can run
  #  docker logs mc
  #  docker exec -i mc rcon-cli
  # Once in rcon-cli you can "op <player_id>" to make someone an operator (admin)
  # Use 'sudo journalctl -u google-startup-scripts.service' to retrieve the startup script output
  metadata_startup_script = "docker run -d -p 25565:25565 -e EULA=TRUE -e VERSION=1.12.2 -v /var/minecraft:/data --name mc -e TYPE=FORGE -e FORGEVERSION=14.23.0.2552 -e MEMORY=2G --rm=true itzg/minecraft-server:latest;"

  metadata = {
    enable-oslogin = "TRUE"
  }
      
  boot_disk {
    auto_delete = false # Keep disk after shutdown (game data)
    source      = google_compute_disk.minecraft.self_link
  }

  network_interface {
    network = google_compute_network.minecraft.name
    access_config {
      nat_ip = google_compute_address.minecraft.address
    }
  }

  service_account {
    email  = google_service_account.minecraft.email
    scopes = ["userinfo-email"]
  }

  scheduling {
    preemptible       = true # Closes within 24 hours (sometimes sooner)
    automatic_restart = false
  }
}

# Create a private network so the minecraft instance cannot access
# any other resources.
resource "google_compute_network" "minecraft" {
  name = "minecraft"
}

# Open the firewall for Minecraft traffic
resource "google_compute_firewall" "minecraft" {
  name    = "minecraft"
  network = google_compute_network.minecraft.name
  # Minecraft client port
  allow {
    protocol = "tcp"
    ports    = ["25565"]
  }
  # ICMP (ping)
  allow {
    protocol = "icmp"
  }
  # SSH (for RCON-CLI access)
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["minecraft"]
}

resource "google_project_iam_custom_role" "minecraftSwitcher" {
  role_id     = "MinecraftSwitcher"
  title       = "Minecraft Switcher"
  description = "Can turn a VM on and off"
  permissions = ["compute.instances.start", "compute.instances.stop", "compute.instances.get"]
}

resource "google_project_iam_custom_role" "instanceLister" {
  role_id     = "InstanceLister"
  title       = "Instance Lister"
  description = "Can list VMs in project"
  permissions = ["compute.instances.list"]
}

resource "google_compute_instance_iam_member" "switcher" {
  count = local.enable_switch_access_group
  project = local.project
  zone = local.zone
  instance_name = google_compute_instance.minecraft.name
  role = google_project_iam_custom_role.minecraftSwitcher.id
  member = "group:${local.minecraft_switch_access_group}"
}

resource "google_project_iam_member" "projectBrowsers" {
  count = local.enable_switch_access_group
  project = local.project
  role    = "roles/browser"
  member  = "group:${local.minecraft_switch_access_group}"
}

resource "google_project_iam_member" "computeViewer" {
  count = local.enable_switch_access_group
  project = local.project
  role    = google_project_iam_custom_role.instanceLister.id
  member  = "group:${local.minecraft_switch_access_group}"
}
