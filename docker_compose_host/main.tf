resource "null_resource" "provisioners" {
  triggers = {
    docker_host_ip      = "${var.public_ip}"                        # whenever the docker host on which docker-compose runs changes, re-run the provisioners
    reprovision_trigger = "${sha1("${local.reprovision_trigger}")}" # whenever the docker-compose config, environment etc changes, re-run the provisioners
  }

  connection {
    host        = "${var.public_ip}"
    user        = "${var.ssh_username}"
    private_key = "${var.ssh_private_key}"
    agent       = false
  }

  provisioner "remote-exec" {
    inline = [<<EOF
command -v docker-compose && (docker-compose -v | grep ${var.docker_compose_version})
if [ "$?" -gt 0 ]; then
  sudo curl -L https://github.com/docker/compose/releases/download/${var.docker_compose_version}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose # https://docs.docker.com/compose/install/
  sudo chmod +x /usr/local/bin/docker-compose
  echo "docker-compose (${var.docker_compose_version}) installed"
else
  echo "docker-compose (${var.docker_compose_version}) already installed"
fi
EOF
    ]
  }

  provisioner "file" {
    content     = "${var.docker_compose_env}"
    destination = "/home/${var.ssh_username}/.env"
  }

  provisioner "file" {
    content     = "${var.docker_compose_yml}"
    destination = "/home/${var.ssh_username}/docker-compose.yml"
  }

  provisioner "file" {
    content     = "${var.docker_compose_override_yml}"
    destination = "/home/${var.ssh_username}/docker-compose.override.yml"
  }

  provisioner "remote-exec" {
    inline = ["${var.docker_compose_up_command}"]
  }

  provisioner "remote-exec" {
    when   = "destroy"
    inline = ["${var.docker_compose_down_command}"]
  }
}
