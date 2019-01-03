output "docker_host_public_ip" {
  description = "Public IP address assigned to the host by EC2"
  value       = "${module.host.docker_host_public_ip}"
}

output "docker_host_instance_id" {
  description = "AWS ID for the EC2 instance used"
  value       = "${module.host.docker_host_instance_id}"
}

output "docker_host_username" {
  description = "Username that can be used to access the EC2 instance over SSH"
  value       = "${module.host.docker_host_username}"
}

output "docker_host_ssh_private_key" {
  description = "SSH private key that can be used to access the EC2 instance"
  value       = "${module.host.docker_host_ssh_private_key}"
}

output "null_resource_static_trigger" {
  description = "This output can be used as e.g. a trigger in a resource as a `depends_on` workaround" # See https://github.com/hashicorp/terraform/issues/18239#issuecomment-401187835
  value       = "${null_resource.provisioners.triggers.static_trigger}"
}

output "jenkins_docker_image_name" {
  value = "${var.jenkins_docker_image_name}"
}

