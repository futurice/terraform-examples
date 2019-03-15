#!/bin/bash

# https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-using-the-convenience-script
curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

# https://docs.docker.com/compose/install/
sudo curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Allow using docker without sudo
sudo usermod -aG docker $(whoami)

# https://success.docker.com/article/how-to-setup-log-rotation-post-installation
echo '{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "5"
  }
}
' | sudo tee /etc/docker/daemon.json
sudo service docker restart # restart the daemon so the settings take effect
