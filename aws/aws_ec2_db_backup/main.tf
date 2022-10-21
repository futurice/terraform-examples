// Creating the database

resource "aws_security_group" "sg_db_primary" {
  name        = var.sg_db_primary_data.name
  description = var.sg_db_primary_data.description
  vpc_id      = var.sg_db_primary_data.vpc_id

  # ingress is an object. 
  dynamic "ingress" {
    for_each = var.sg_db_primary_data.ingress_rules

    content {
      # An item consists of "KEY" & "VALUE"
      # KEY is the MAP KEY or LIST ELEMENT INDEX for the current element
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
      security_groups  = ingress.value.security_groups
    }
  }

  dynamic "egress" {
    for_each = var.sg_db_primary_data.egress_rules

    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
      security_groups  = egress.value.security_groups
    }
  }

  tags = {
    "Name" = "${var.sg_db_primary_data.name}"
  }
}

// Getting the latest snapshot
data "aws_ebs_snapshot" "xvda_snapshot" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["${var.cp_db_snapshot_data.tag_name}"]
  }
}

// Creating AWS AMI from the snapshot. Changes to 
resource "aws_ami" "cp_db_ami" {
  name                = "cp_db_ami"
  virtualization_type = "hvm"
  root_device_name    = "/dev/xvda"

  ebs_block_device {
    device_name = "/dev/xvda"
    snapshot_id = data.aws_ebs_snapshot.xvda_snapshot.id
    volume_size = var.cp_db_ami_data.volume_size
    volume_type = var.cp_db_ami_data.volume_type
  }

  tags = {
    Name = "cp_db_ami"
  }
}

// Creating an instance from the image
resource "aws_instance" "cp_db_primary" {
  ami           = aws_ami.cp_db_ami.id
  instance_type = var.cp_db_primary_instance_data.instance_type
  key_name      = var.cp_db_primary_instance_data.key_name

  subnet_id              = var.cp_db_primary_instance_data.subnet_id
  vpc_security_group_ids = [aws_security_group.sg_db_primary.id]

  tags = {
    Name = var.cp_db_primary_instance_data.name
  }

  // Create snapshot of data volume before destroying
  provisioner "local-exec" {
    on_failure = fail
    when       = destroy
    # attachment.device value "/dev/xvda" should be the same as the variable
    # Tag "cp-db-snapshot" should be the same as the variable
    command = "aws ec2 create-snapshot --description xvda-data-snapshot --volume-id $(aws ec2 describe-volumes --filters Name=attachment.instance-id,Values=${self.id} Name=attachment.device,Values=/dev/xvda --query 'Volumes[*].{ID:VolumeId}' --output text) --tag-specifications 'ResourceType=snapshot,Tags=[{Key=Name,Value=cp-db-snapshot},{Key=created-when,Value=on-destroy}]'"
  }
}

resource "aws_iam_role" "dlm_lifecycle_role" {
  name = "dlm-lifecycle-role"

  assume_role_policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "dlm.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
}
EOF
}

resource "aws_iam_role_policy" "dlm_lifecycle" {
  name = "dlm-lifecycle-policy"
  role = aws_iam_role.dlm_lifecycle_role.id

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
        {
        "Effect": "Allow",
        "Action": [
          "ec2:CreateSnapshot",
          "ec2:CreateSnapshots",
          "ec2:DeleteSnapshot",
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:EnableFastSnapshotRestores",
          "ec2:DescribeFastSnapshotRestores",
          "ec2:DisableFastSnapshotRestores",
          "ec2:CopySnapshot",
          "ec2:ModifySnapshotAttribute",
          "ec2:DescribeSnapshotAttribute"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:CreateTags"
        ],
        "Resource": "arn:aws:ec2:*::snapshot/*"
      }
   ]
}
EOF
}

// data lifecycle manager, data lifecycle policy
resource "aws_dlm_lifecycle_policy" "cp_db_dlm_policy" {
  description        = "CP Database DLM lifecycle policy"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "2 daily snapshots for 1 week"

      # every 12 hours starting at 00:00 AM IST
      create_rule {
        interval      = 12
        interval_unit = "HOURS"
        # UTC 18:30 ==> IST 00:00 AM
        times = ["18:30"]
      }

      retain_rule {
        count = 14
      }

      tags_to_add = {
        Name         = "${var.cp_db_snapshot_data.tag_name}"
        created-when = "daily-backup"
      }

      copy_tags = false
    }

    target_tags = {
      Name = "${var.cp_db_snapshot_data.tag_name}"
    }
  }

  tags = {
    Name = "cp_db_dlm_policy"
  }
}

