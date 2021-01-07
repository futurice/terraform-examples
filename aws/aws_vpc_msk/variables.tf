# Standard Variables

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws-profile" {
  description = "Local AWS Profile Name "
  type        = string
}

variable "environment" {
  description = "AWS Environment"
  type        = string
}

variable "application" {
  type    = string
  default = "acm"
}

# VPC Variables

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "Private subnet  - CIDR"
  type        = list
}
variable "public_subnet_cidrs" {
  description = "Private subnet  - CIDR"
  type        = list
}

# MSK Cluster

variable "msk_cluster_version" {
  type    = string
  default = "2.4.1.1"
}

variable "broker_nodes" {
  default = 3
}

variable "msk_cluster_instance_type" {
  type    = string
  default = "kafka.m5.large"
}

variable "msk_ebs_volume_size" {
  default = 100
}

variable "encryption_type" {
  type    = string
  default = "TLS_PLAINTEXT"
}

variable "monitoring_type" {
  type    = string
  default = "PER_BROKER"
}

# MSK Client

variable "key_name" {
  type    = string
  default = "MSK-Keypair"
}

variable "msk_instance_type" {
  type    = string
  default = "m5.large"
}

variable "msk_ami" {
  type    = string
  default = "ami-04d29b6f966df1537"
}