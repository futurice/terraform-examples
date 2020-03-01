# Whenever the contents of this block changes, the host should be re-provisioned
locals {
  reprovision_trigger = <<EOF
    # Trigger reprovision on variable changes:
    ${var.hostname}
    ${var.ssh_username}
    ${var.ssh_private_key_path}
    ${var.ssh_public_key_path}
    ${var.swap_file_size}
    ${var.swap_swappiness}
    ${var.reprovision_trigger}
    # Trigger reprovision on file changes:
    ${file("${path.module}/provision-docker.sh")}
    ${file("${path.module}/provision-ebs.sh")}
    ${file("${path.module}/provision-swap.sh")}
  EOF
}

locals {
  availability_zone = "${data.aws_availability_zones.this.names[0]}" # use the first available AZ in the region (AWS ensures this is constant per user)
}

variable "hostname" {
  description = "Hostname by which this service is identified in metrics, logs etc"
  default     = "aws-ec2-ebs-docker-host"
}

variable "instance_type" {
  description = "See https://aws.amazon.com/ec2/instance-types/ for options; for example, typical values for small workloads are `\"t2.nano\"`, `\"t2.micro\"`, `\"t2.small\"`, `\"t2.medium\"`, and `\"t2.large\"`"
  default     = "t2.micro"
}

variable "instance_ami" {
  description = "See https://cloud-images.ubuntu.com/locator/ec2/ for options"
  default     = "ami-0bdf93799014acdc4"                                        # Ubuntu 18.04.1 LTS (eu-central-1, amd64, hvm:ebs-ssd, 2018-09-12)
}

variable "ssh_private_key_path" {
  description = "SSH private key file path, relative to Terraform project root"
  default     = "ssh.private.key"
}

variable "ssh_public_key_path" {
  description = "SSH public key file path, relative to Terraform project root"
  default     = "ssh.public.key"
}

variable "ssh_username" {
  description = "Default username built into the AMI (see 'instance_ami')"
  default     = "ubuntu"
}

variable "vpc_id" {
  description = "ID of the VPC our host should join; if empty, joins your Default VPC"
  default     = ""
}

variable "reprovision_trigger" {
  description = "An arbitrary string value; when this value changes, the host needs to be reprovisioned"
  default     = ""
}

variable "root_volume_size" {
  description = "Size (in GiB) of the EBS volume that will be created and mounted as the root fs for the host"
  default     = 8                                                                                              # this matches the other defaults, including the selected AMI
}

variable "data_volume_id" {
  description = "The ID of the EBS volume to mount as `/data`"
  default     = ""                                             # empty string means no EBS volume will be attached
}

variable "swap_file_size" {
  description = "Size of the swap file allocated on the root volume"
  default     = "512M"                                               # a smallish default to match default 8 GiB EBS root volume
}

variable "swap_swappiness" {
  description = "Swappiness value provided when creating the swap file"
  default     = "10"                                                    # 100 will make the host use the swap as much as possible, 0 will make it use only in case of emergency
}

variable "allow_incoming_http" {
  description = "Whether to allow incoming HTTP traffic on the host security group"
  default     = false
}

variable "allow_incoming_https" {
  description = "Whether to allow incoming HTTPS traffic on the host security group"
  default     = false
}

variable "allow_incoming_dns" {
  description = "Whether to allow incoming DNS traffic on the host security group"
  default     = false
}

variable "tags" {
  description = "AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/"
  type        = "map"
  default     = {}
}
