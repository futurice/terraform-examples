# Access data about available availability zones in the current region
data "aws_availability_zones" "this" {}

# Comment which should be added to all resources we create
locals {
  default_description = "Managed by Terraform"
}

# Our default security group to access to the instances, over specific protocols
resource "aws_security_group" "this" {
  description = "${local.default_description}"
  vpc_id      = "${var.docker_host_aws_vpc_id}"

  tags {
    Name = "${var.docker_host_hostname}"
  }
}

# Whenever the contents of this block changes, the host should be re-provisioned
locals {
  reprovision_trigger = <<EOF
    # Trigger reprovision on variable changes:
    ${var.docker_host_hostname}
    ${var.docker_host_instance_username}
    ${var.docker_host_backup_cron_expression}
    ${var.docker_host_backup_sources}
    ${var.docker_host_reprovision_trigger}
    # Trigger reprovision on secrets changes:
    ${var.provisioner_ssh_public_key}
    ${var.provisioner_ssh_private_key}
    # Trigger reprovision on file changes:
    ${file("${path.module}/docker-compose.yml")}
    ${file("${path.module}/nginx-status.conf")}
    ${file("${path.module}/provision.sh")}
  EOF
}

# Define incoming/outgoing network access rules for the VPC

resource "aws_security_group_rule" "incoming_ssh" {
  security_group_id = "${aws_security_group.this.id}"
  type              = "ingress"
  description       = "${local.default_description}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "incoming_http" {
  security_group_id = "${aws_security_group.this.id}"
  type              = "ingress"
  description       = "${local.default_description}"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "incoming_https" {
  security_group_id = "${aws_security_group.this.id}"
  type              = "ingress"
  description       = "${local.default_description}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outgoing_any" {
  security_group_id = "${aws_security_group.this.id}"
  type              = "egress"
  description       = "${local.default_description}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Create an SSH key pair for accessing the EC2 instance
resource "aws_key_pair" "this" {
  public_key = "${var.provisioner_ssh_public_key}"
}

# Create the main EC2 instance
# https://www.terraform.io/docs/providers/aws/r/instance.html
resource "aws_instance" "this" {
  instance_type          = "${var.docker_host_instance_type}"
  ami                    = "${var.docker_host_instance_ami}"
  availability_zone      = "${data.aws_availability_zones.this.names[0]}" # use the first available AZ in the region (AWS ensures this is constant per user)
  key_name               = "${aws_key_pair.this.id}"                      # the name of the SSH keypair to use for provisioning
  vpc_security_group_ids = ["${aws_security_group.this.id}"]
  subnet_id              = "${var.docker_host_aws_subnet_id}"
  user_data              = "${sha1(local.reprovision_trigger)}"           # this value isn't used by the EC2 instance, but its change will trigger re-creation of the resource

  tags {
    Name = "${var.docker_host_hostname}"
  }

  connection {
    user        = "${var.docker_host_instance_username}"
    private_key = "${var.provisioner_ssh_private_key}"
    agent       = false                                                           # don't use SSH agent because we have the private key right here
  }

  # Set hostname
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${var.docker_host_hostname}",
      "echo 127.0.0.1 ${var.docker_host_hostname} | sudo tee -a /etc/hosts", # https://askubuntu.com/a/59517
    ]
  }

  # Install docker & compose
  provisioner "remote-exec" {
    script = "${path.module}/provision.sh"
  }

  # Transfer over some secrets for docker-compose
  provisioner "file" {
    content = <<EOF
COMPOSE_PROJECT_NAME=compose
DOCKER_HOST_HOSTNAME=${var.docker_host_hostname}
BACKUP_CRON_EXPRESSION=${var.docker_host_backup_cron_expression}
BACKUP_SOURCES=${var.docker_host_backup_sources}
AWS_S3_BUCKET_NAME=${aws_s3_bucket.backup.id}
AWS_ACCESS_KEY_ID=${aws_iam_access_key.backup.id}
AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.backup.secret}
AWS_DEFAULT_REGION=${data.aws_region.backup.name}
EOF

    destination = "/home/${var.docker_host_instance_username}/.env"
  }

  # Copy base docker-compose file
  provisioner "file" {
    source      = "${path.module}/docker-compose.yml"
    destination = "/home/${var.docker_host_instance_username}/docker-compose.yml"
  }

  # Copy over nginx-status config
  provisioner "file" {
    source      = "${path.module}/nginx-status.conf"
    destination = "/home/${var.docker_host_instance_username}/nginx-status.conf"
  }

  # Pull images for the support services
  provisioner "remote-exec" {
    inline = ["echo Pulling docker images...; docker-compose pull --quiet"]
  }
}
