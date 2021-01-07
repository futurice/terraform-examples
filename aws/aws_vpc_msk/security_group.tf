resource "aws_security_group" "KafkaClusterSG" {
  name        = "msk-${lower(var.environment)}-sg-${random_uuid.randuuid.result}"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.msk_vpc.id

  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common-tags,
    map(
      "Name", "msk-${lower(var.environment)}-sg-${random_uuid.randuuid.result}"
    )
  )
}

resource "aws_security_group" "KafkaClientInstanceSG" {
  name        = "KafkaClientInstanceSG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.msk_vpc.id

  ingress {
    description = "SSH port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common-tags,
    map(
      "Name", "KafkaClientInstanceSG"
    )
  )
}