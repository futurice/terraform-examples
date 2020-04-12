# Economical Minecraft server

A safe Minecraft server that won't break the bank. Game data is preserved across sessions. Server is hosted on a permenant IP address. You need to start the VM each session, but it will shutdown within 24 hours if you forget to turn it off. Process is run in a sandboxed VM, so any server exploits cannot do any serious damage.

We are experimenting with providing support through a [google doc](https://docs.google.com/document/d/1TXyzHKqoKMS-jY9FSMrYNLEGathqSG8YuHdj0Z9GP34).

Help us make this simple for others to use by asking for help.

Launch blog can be found [here](https://www.futurice.com/blog/friends-and-family-minecraft-server-terraform-recipe) 

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

