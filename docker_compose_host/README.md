# docker_compose_host

Provisions an existing host to run services defined in a `docker-compose.yml` file.

This is a convenient companion to [`aws_ec2_ebs_docker_host`](https://github.com/futurice/terraform-utils/tree/master/aws_ec2_ebs_docker_host), though any Debian-like host reachable over SSH should work.

Changing the contents of your `docker-compose.yml` file (or any other variables defined for this module) will trigger re-creation of the containers on the next `terraform apply`.

## Example

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up:

```tf
module "my_host" {
  # Check for updates at: https://github.com/futurice/terraform-utils/compare/v4.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_ec2_ebs_docker_host?ref=v4.0"

  hostname             = "my-docker-host"
  ssh_private_key_path = "~/.ssh/id_rsa"
  ssh_public_key_path  = "~/.ssh/id_rsa.pub"
  allow_incoming_http  = true
  reprovision_trigger  = "${module.my_docker_compose.reprovision_trigger}"
}

module "my_docker_compose" {
  # Check for updates at: https://github.com/futurice/terraform-utils/compare/v4.0...master
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//docker_compose_host?ref=v4.0"

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
