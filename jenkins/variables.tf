variable "jenkins_aws_iam_user" {
  description = "IAM user name for Jenkins (used to create the agents IAM policy)"
}

variable "jenkins_aws_iam_policy_name" {
  description = "IAM policy name for Jenkins (used to create the agents IAM policy)"
  default     = "terraform_jenkins_agents"
}

variable "master_hostname" {
  description = "Hostname by which this service is identified in metrics, logs etc"
}

variable "master_instance_type" {
  description = "See https://aws.amazon.com/ec2/instance-types/ for options"
  default     = "t2.micro"                                                   # after changing this, you may need to apply again, otherwise Terraform may miss the public IP change
}

variable "master_aws_vpc_id" {
  description = "ID of the externally-created AWS VPC which our EC2 machines should join"
}

variable "master_aws_subnet_id" {
  description = "ID of the externally-created AWS VPC subnet which our EC2 machines should join"
}

variable "master_dns_domain" {
  description = "Domain on which this host is available"
}

variable "master_dns_zone" {
  description = "Route 53 Zone ID on which to keep the DNS record for the host"
}

variable "master_admin_username" {
  description = "Username for the Jenkins admin user"
}


variable "master_admin_password" {
  description = "Password for the Jenkins admin user"
}

variable "master_private_key" {
  description = "Private key used by the master to ssh into an agent"
}

variable "master_public_key" {
  description = "Public key to be injected into the agents so that master can ssh into them (the counterpart of `master_private_key`)"
}

variable "agent_instance_ami" {
  description = "AMI for the EC2 agents"
  default     = "ami-c7e9e72c"           # ami-c7e9e72c = eu-central-1, Amazon ECS-Optimized AMI. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
}

variable "agent_termination_minutes" {
  description = "Idle time before an agent is shut down"
}

variable "agent_instances_cap" {
  description = "Maximum amount of EC2 agents"
}

variable "agent_instance_username" {
  description = "Username on the agent instance"
  default     = "ec2-user"
}

variable "agent_aws_subnet_id" {
  description = "ID of the externally-created AWS VPC subnet which our EC2 machines should join"
}

variable "agent_instance_type" {
  description = "See https://aws.amazon.com/ec2/instance-types/ for options"
  default     = "t2.medium"                                                  # after changing this, you may need to apply again, otherwise Terraform may miss the public IP change
}

variable "master_credentials_instructions" {
  description = "Instructions to run in the credentials creation script (see README)"
  default     = ""
}

variable "jenkins_docker_image_name" {
  description = "Name of the docker image for the Jenkins Dockerfile (useful to 'extend' it with a `FROM` from outside)"
  default     = "futurice_terraform_utils_jenkins"
}

variable "docker_host_provisioner_ssh_public_key" {
  description = "Public key that will be used to provision the master EC2 instance"
}

variable "docker_host_provisioner_ssh_private_key" {
  description = "Private key corresponding to the previously mentioned public key"
}

data "template_file" "ec2_plugin_configuration_file" {
  template = "${file("${path.module}/ec2-plugin-configuration.groovy.tpl")}"

  vars {
    master_private_key            = "${var.master_private_key}"
    agent_instance_ami            = "${var.agent_instance_ami}"
    agent_termination_minutes     = "${var.agent_termination_minutes}"
    agent_instances_cap           = "${var.agent_instances_cap}"
    agent_instance_username       = "${var.agent_instance_username}"
    agent_aws_security_group_id   = "${aws_security_group.jenkins_agent.id}"
    agent_aws_subnet_id           = "${var.agent_aws_subnet_id}"
    agent_instance_type           = "${var.agent_instance_type}"
    agent_iam_user_aws_access_key = "${aws_iam_access_key.jenkins_user.id}"
    agent_iam_user_aws_secret_key = "${aws_iam_access_key.jenkins_user.secret}"
  }
}

data "template_file" "jekins_setup" {
  template = "${file("${path.module}/setup.groovy.tpl")}"

  vars {
    jenkins_url = "${var.master_dns_domain}"
  }
}

data "template_file" "jenkins_credentials" {
  template = "${file("${path.module}/credentials.groovy.tpl")}"

  vars {
    instructions = "${var.master_credentials_instructions}"
  }
}

