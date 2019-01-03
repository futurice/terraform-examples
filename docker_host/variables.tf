variable "docker_host_hostname" {
  description = "Hostname by which this service is identified in metrics, logs etc"
}

variable "docker_host_instance_type" {
  description = "See https://aws.amazon.com/ec2/instance-types/ for options"
  default     = "t2.micro"                                                   # after changing this, you may need to apply again, otherwise Terraform may miss the public IP change
}

variable "docker_host_instance_ami" {
  description = "See https://cloud-images.ubuntu.com/locator/ec2/ for options"
  default     = "ami-0bdf93799014acdc4"                                        # Ubuntu 18.04.1 LTS (eu-central-1, amd64, hvm:ebs-ssd, 2018-09-12)
}

variable "docker_host_instance_username" {
  description = "Default username built into the AMI (docker_host_instance_ami)"
  default     = "ubuntu"
}

variable "docker_host_aws_vpc_id" {
  description = "ID of the externally-created AWS VPC which our EC2 machines should join"
}

variable "docker_host_aws_subnet_id" {
  description = "ID of the externally-created AWS VPC subnet which our EC2 machines should join"
}

variable "docker_host_backup_cron_expression" {
  description = "How often should the data volume of this host be backed up to S3"
  default     = "0 4 * * *"                                                        # back up at 4 AM (see e.g. https://crontab.guru/)
}

variable "docker_host_backup_sources" {
  description = "Which path(s) should the backup include"
  default     = "/data"
}

variable "docker_host_reprovision_trigger" {
  description = "An arbitrary string value; when this value changes, the host needs to be reprovisioned"
  default     = ""
}

variable "provisioner_ssh_public_key" {
  description = "Public key that will be used to provision the EC2 instances"
}

variable "provisioner_ssh_private_key" {
  description = "Private key corresponding to the previously mentioned public key"
}

