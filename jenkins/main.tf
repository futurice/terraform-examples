# Whenever the contents of this block changes, the host should be re-provisioned
locals {
  reprovision_trigger = <<EOF
    # Trigger reprovision on file changes:
    ${file("${path.module}/credentials.groovy.tpl")}
    ${file("${path.module}/docker-compose.yml")}
    ${file("${path.module}/Dockerfile")}
    ${file("${path.module}/ec2-plugin-configuration.groovy.tpl")}
    ${file("${path.module}/provision-jenkins.sh")}
    ${file("${path.module}/security.groovy")}
    ${file("${path.module}/setup.groovy.tpl")}
  EOF
}

# https://www.terraform.io/docs/providers/aws/r/iam_user.html
resource "aws_iam_user" "jenkins_user" {
  name = "${var.jenkins_aws_iam_user}"
}

# https://www.terraform.io/docs/providers/aws/r/iam_access_key.html
resource "aws_iam_access_key" "jenkins_user" {
  user = "${aws_iam_user.jenkins_user.name}"
}

# https://www.terraform.io/docs/providers/aws/r/iam_user_policy.html
resource "aws_iam_user_policy" "jenkins_user" {
  name = "${var.jenkins_aws_iam_policy_name}"
  user = "${aws_iam_user.jenkins_user.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "ec2:DescribeSpotInstanceRequests",
        "ec2:CancelSpotInstanceRequests",
        "ec2:GetConsoleOutput",
        "ec2:RequestSpotInstances",
        "ec2:RunInstances",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DescribeInstances",
        "ec2:DescribeKeyPairs",
        "ec2:DescribeRegions",
        "ec2:DescribeImages",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "iam:ListInstanceProfilesForRole",
        "iam:PassRole"
      ]
    }
  ]
}
EOF
}

resource "aws_key_pair" "this" {
  public_key = "${var.master_public_key}"
}

module "host" {
  source                          = "git::https://github.com/futurice/terraform-utils.git//docker_host"
  docker_host_hostname            = "${var.master_hostname}"
  docker_host_instance_type       = "${var.master_instance_type}"
  docker_host_aws_vpc_id          = "${var.master_aws_vpc_id}"
  docker_host_aws_subnet_id       = "${var.master_aws_subnet_id}"
  docker_host_reprovision_trigger = "${sha1(local.reprovision_trigger)}"
  provisioner_ssh_public_key      = "${var.docker_host_provisioner_ssh_public_key}"
  provisioner_ssh_private_key     = "${var.docker_host_provisioner_ssh_private_key}"
}

resource "aws_ebs_volume" "this" {
  availability_zone = "${module.host.docker_host_instance_az}" # use the same AZ as the host
  type              = "gp2"                                    # i.e. "Amazon EBS General Purpose SSD"
  size              = 10                                       # in GB; after changing this, you need to SSH over and run e.g. $ sudo resize2fs /dev/xvdh

  tags {
    Name = "${var.master_hostname}"
  }
}

# Attach the separate data volume to the instance, if it exists
resource "aws_volume_attachment" "this" {
  device_name = "/dev/xvdh"                              # note: this can't be arbitrarily changed!
  instance_id = "${module.host.docker_host_instance_id}"
  volume_id   = "${aws_ebs_volume.this.id}"
}

resource "aws_route53_record" "this" {
  zone_id = "${var.master_dns_zone}"
  name    = "${var.master_dns_domain}"
  type    = "A"
  ttl     = 60
  records = ["${module.host.docker_host_public_ip}"]
}

resource "aws_security_group" "jenkins_agent" {
  vpc_id = "${var.master_aws_vpc_id}"

  tags {
    Name = "jenkins_agent"
  }
}

# Define incoming/outgoing network access rules for the VPC

resource "aws_security_group_rule" "incoming_ssh" {
  security_group_id = "${aws_security_group.jenkins_agent.id}"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outgoing_any" {
  security_group_id = "${aws_security_group.jenkins_agent.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Provisioners for setting up the host, once it's up
resource "null_resource" "provisioners" {
  depends_on = [
    "aws_volume_attachment.this", # because we depend on the EBS volume being available
    "aws_security_group.jenkins_agent", # because Jenkins won't be able to create any agents unless their Security Group exists
  ]

  triggers {
    docker_host_instance_id = "${module.host.docker_host_instance_id}" # if the docker_host is re-provisioned, ensure these provisioners also re-run
    static_trigger          = "jenkins.null_resource"
  }

  connection {
    host        = "${module.host.docker_host_public_ip}"
    user        = "${module.host.docker_host_username}"
    private_key = "${module.host.docker_host_ssh_private_key}"
    agent       = false                                        # don't use SSH agent because we have the private key right here
  }

  # Prepare & mount EBS volume
  provisioner "remote-exec" {
    script = "./provision-ebs-volume.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "echo MASTER_DOMAIN='${var.master_dns_domain}' >> .env",
      "echo MASTER_ADMIN_USERNAME='${var.master_admin_username}' >> .env",
      "echo MASTER_ADMIN_PASSWORD='${var.master_admin_password}' >> .env",
    ]
  }

  # Create the jenkins data directory and set the permissions so that the jenkins user can write it
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /data/jenkins",
      "sudo chown -R 1000:1000 /data/jenkins",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/security.groovy"
    destination = "/home/${module.host.docker_host_username}/security.groovy"
  }

  provisioner "file" {
    content     = "${data.template_file.jenkins_credentials.rendered}"
    destination = "/home/${module.host.docker_host_username}/credentials.groovy"
  }

  provisioner "file" {
    content     = "${data.template_file.ec2_plugin_configuration_file.rendered}"
    destination = "/home/${module.host.docker_host_username}/ec2-plugin-configuration.groovy"
  }

  # Copy Dockerfile
  provisioner "file" {
    source      = "${path.module}/Dockerfile"
    destination = "/home/${module.host.docker_host_username}/Dockerfile"
  }

  # Copy docker-compose config
  provisioner "file" {
    source      = "${path.module}/docker-compose.yml"
    destination = "/home/${module.host.docker_host_username}/docker-compose.override.yml"
  }

  provisioner "file" {
    content     = "${data.template_file.jekins_setup.rendered}"
    destination = "/home/${module.host.docker_host_username}/setup.groovy"
  }

  # Pull images
  provisioner "remote-exec" {
    inline = ["echo Pulling docker images...; docker-compose pull --quiet ; docker-compose build --no-cache"]
  }

  # Start services
  provisioner "remote-exec" {
    inline = ["docker-compose up -d"]
  }

  provisioner "file" {
    source      = "${path.module}/provision-jenkins.sh"
    destination = "/home/${module.host.docker_host_username}/provision-jenkins.sh"
  }

  provisioner "remote-exec" {
    inline = ["sh /home/${module.host.docker_host_username}/provision-jenkins.sh ${var.master_admin_username} ${var.master_admin_password}"]
  }

  provisioner "remote-exec" {
    inline = ["docker build -t ${var.jenkins_docker_image_name} /home/${module.host.docker_host_username}"]
  }
}
