# docker_compose_host

Provisions an existing host to run services defined in a `docker-compose.yml` file.

This is a convenient companion to [`aws_ec2_ebs_docker_host`](https://github.com/futurice/terraform-utils/tree/master/aws_ec2_ebs_docker_host), though any Debian-like host reachable over SSH should work.

Changing the contents of your `docker-compose.yml` file (or any other variables defined for this module) will trigger re-creation of the containers on the next `terraform apply`.

## Example

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up:

```tf
module "my_host" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/docker_compose_host#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_ec2_ebs_docker_host?ref=v11.0"

  hostname             = "my-docker-host"
  ssh_private_key_path = "~/.ssh/id_rsa"
  ssh_public_key_path  = "~/.ssh/id_rsa.pub"
  allow_incoming_http  = true
  reprovision_trigger  = "${module.my_docker_compose.reprovision_trigger}"
}

module "my_docker_compose" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/docker_compose_host#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v11.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//docker_compose_host?ref=v11.0"

  public_ip          = "${module.my_host.public_ip}"
  ssh_username       = "${module.my_host.ssh_username}"
  ssh_private_key    = "${module.my_host.ssh_private_key}"
  docker_compose_yml = "${file("./docker-compose.yml")}"
}

output "test_link" {
  value = "http://${module.my_host.public_ip}/"
}
```

In your `docker-compose.yml` file, try:

```yml
version: "3"
services:
  nginx:
    image: nginx
    ports:
      - "80:80"
```

After a `terraform apply`, you should be able to visit the `test_link` and see nginx greeting you.

Any changes to the compose file trigger re-provisioning of the services. For example, try changing your services to:

```yml
version: "3"
services:
  whoami:
    image: jwilder/whoami
    ports:
      - "80:8000"
```

When running `terraform apply`, the previous `nginx` service will be stopped and removed, and then the new `whoami` service will be started in its stead. Visiting the `test_link` URL again should give you a different result now.

<!-- terraform-docs:begin -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| docker_compose_down_command | Command to remove services with; will be run during un- or re-provisioning | string | `"docker-compose stop 00260026 docker-compose rm -f"` | no |
| docker_compose_env | Env-vars (in `.env` file syntax) that will be substituted into docker-compose.yml (see https://docs.docker.com/compose/environment-variables/#the-env-file) | string | `"# No env-vars set"` | no |
| docker_compose_override_yml | Contents for the `docker-compose.override.yml` file (see https://docs.docker.com/compose/extends/#multiple-compose-files) | string | `"# Any docker-compose services defined here will be merged on top of docker-compose.yml
# See: https://docs.docker.com/compose/extends/#multiple-compose-files
version: "3"
"` | no |
| docker_compose_up_command | Command to start services with; you can customize this to do work before/after, or to disable this completely in favor of your own provisioning scripts | string | `"docker-compose pull --quiet 00260026 docker-compose up -d"` | no |
| docker_compose_version | Version of docker-compose to install during provisioning (see https://github.com/docker/compose/releases) | string | `"1.23.2"` | no |
| docker_compose_yml | Contents for the `docker-compose.yml` file | string | n/a | yes |
| public_ip | Public IP address of a host running docker | string | n/a | yes |
| ssh_private_key | SSH private key, which can be used for provisioning the host | string | n/a | yes |
| ssh_username | SSH username, which can be used for provisioning the host | string | `"ubuntu"` | no |

## Outputs

| Name | Description |
|------|-------------|
| reprovision_trigger | Hash of all docker-compose configuration used for this host; can be used as the `reprovision_trigger` input to an `aws_ec2_ebs_docker_host` module |
<!-- terraform-docs:end -->
