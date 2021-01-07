resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "msk_cluster_cloudwatch_group-${random_uuid.randuuid.result}"
}

resource "aws_msk_configuration" "msk_cluster_config" {
  kafka_versions = [var.msk_cluster_version]
  name           = "msk-${lower(var.environment)}-cluster-cfg-${random_uuid.randuuid.result}"
  server_properties = <<PROPERTIES
auto.create.topics.enable = true
delete.topic.enable = true
PROPERTIES
}

resource "aws_msk_cluster" "msk_cluster" {
  count                  = length(var.private_subnet_cidrs)
  cluster_name           = "msk-${lower(var.environment)}-cluster-${random_uuid.randuuid.result}"
  kafka_version          = var.msk_cluster_version
  number_of_broker_nodes = var.broker_nodes

  broker_node_group_info {
    instance_type   = var.msk_cluster_instance_type
    ebs_volume_size = var.msk_ebs_volume_size
    client_subnets = [
      "${aws_subnet.private_subnet.0.id}",
      "${aws_subnet.private_subnet.1.id}",
      "${aws_subnet.private_subnet.2.id}"
    ]
    security_groups = [aws_security_group.KafkaClusterSG.id]
  }

  /*
  client_authentication {
    tls {
      certificate_authority_arns = [aws_acmpca_certificate_authority.pca.arn]
    }
  }
*/

configuration_info {
  arn = aws_msk_configuration.msk_cluster_config.arn
  revision = 1
}
  encryption_info {
    encryption_in_transit {
      client_broker = var.encryption_type
    }
  }

  enhanced_monitoring = var.monitoring_type

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.cloudwatch_log_group.name
      }
    }
  }

  tags = merge(
    local.common-tags,
    map(
      "Name", "msk-${lower(var.environment)}-cluster"
    )
  )
}

output "zookeeper_connect_string" {
  value = aws_msk_cluster.msk_cluster.*.zookeeper_connect_string
}

output "bootstrap_brokers" {
  description = "Plaintext connection host:port pairs"
  value       = aws_msk_cluster.msk_cluster.*.bootstrap_brokers
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.msk_cluster.*.bootstrap_brokers_tls
}