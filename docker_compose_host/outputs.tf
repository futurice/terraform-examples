locals {
  reprovision_trigger = <<EOF
  ${var.docker_compose_version}
  ${var.docker_compose_env}
  ${var.docker_compose_yml}
  ${var.docker_compose_override_yml}
  ${var.docker_compose_up_command}
EOF
}

output "reprovision_trigger" {
  description = "Hash of all docker-compose configuration used for this host; can be used as the `reprovision_trigger` input to an `aws_ec2_ebs_docker_host` module"
  value       = "${sha1("${local.reprovision_trigger}")}"
}
