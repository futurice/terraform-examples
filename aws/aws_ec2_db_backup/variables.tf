variable "sg_db_primary_data" {
  type = object({
    name        = string
    description = string
    vpc_id      = string
    ingress_rules = list(object({
      description      = string
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = list(string)
      ipv6_cidr_blocks = list(string)
      security_groups  = list(string)
    }))
    egress_rules = list(object({
      description      = string
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = list(string)
      ipv6_cidr_blocks = list(string)
      security_groups  = list(string)
    }))
  })
  description = "Security group data for Database EC2 Instance"
}

variable "cp_db_snapshot_data" {
  description = "This is the description that will be used to identify the snapshots of our data volume. We will filter against this value."
  type = object({
    tag_name = string
  })
}

variable "cp_db_ami_data" {
  description = "The cp database ami data"
  type = object({
    volume_size = number
    volume_type = string
  })
}

variable "cp_db_primary_instance_data" {
  description = "Data for the primary database"
  type = object({
    name          = string
    instance_type = string
    key_name      = string
    subnet_id     = string
  })
}
