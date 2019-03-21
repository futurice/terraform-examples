# aws_ec2_ebs_docker_host

Creates a standalone Docker host on EC2, optionally attaching an external EBS volume for persistent data.

This is convenient for quickly setting up non-production-critical Docker workloads. If you need something fancier, consider e.g. ECS, EKS or Fargate.

## Example 1: Running a docker container

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up:

```tf
module "my_host" {
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_ec2_ebs_docker_host?ref=v3.0"

  hostname             = "my-docker-host"
  ssh_private_key_path = "~/.ssh/id_rsa"     # if you use shared Terraform state, consider changing this to something that doesn't depend on "~"
  ssh_public_key_path  = "~/.ssh/id_rsa.pub"
  allow_incoming_http  = true                # by default, only incoming SSH is allowed; other protocols for the security group are opt-in
}

output "host_ssh_command" {
  description = "Run this command to create a port-forward to the remote docker daemon"
  value       = "ssh -i ${module.my_host.ssh_private_key_path} -o StrictHostKeyChecking=no -L localhost:2377:/var/run/docker.sock ${module.my_host.ssh_username}@${module.my_host.public_ip}"
}
```

After `terraform apply`, and running the `host_ssh_command`, you should be able to connect from your local Docker CLI to the remote daemon, e.g.:

```bash
$ DOCKER_HOST=localhost:2377 docker run -d -p 80:80 nginx
```

Visit the IP address of your host in a browser to make sure it works.

## Example 2: Using a persistent data volume

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up:

```tf
resource "aws_ebs_volume" "my_data" {
  availability_zone = "${module.my_host.availability_zone}" # ensure the volume is created in the same AZ the docker host
  type              = "gp2"                                 # i.e. "Amazon EBS General Purpose SSD"
  size              = 25                                    # in GiB; if you change this in-place, you need to SSH over and run e.g. $ sudo resize2fs /dev/xvdh
}

module "my_host" {
  source = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_ec2_ebs_docker_host?ref=v3.0"

  hostname             = "my-host"
  ssh_private_key_path = "~/.ssh/id_rsa"                # note that with a shared Terraform state, paths with "~" will become problematic
  ssh_public_key_path  = "~/.ssh/id_rsa.pub"
  data_volume_id       = "${aws_ebs_volume.my_data.id}" # attach our EBS data volume
}

output "host_ssh_command" {
  description = "Run this command to check that the data volume got mounted"
  value       = "ssh -i ${module.my_host.ssh_private_key_path} -o StrictHostKeyChecking=no ${module.my_host.ssh_username}@${module.my_host.public_ip} df -h"
}

```

Note that due to [a bug in Terraform](https://github.com/hashicorp/terraform/issues/12570), at the time of writing, you need to apply in two parts:

```bash
$ terraform apply -target aws_ebs_volume.my_data
...
$ terraform apply
...
```

Afterwards, running the `host_ssh_command` should give you something like:

```
Filesystem      Size  Used Avail Use% Mounted on
udev            481M     0  481M   0% /dev
tmpfs            99M  752K   98M   1% /run
/dev/xvda1      7.7G  2.1G  5.7G  27% /
tmpfs           492M     0  492M   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           492M     0  492M   0% /sys/fs/cgroup
/dev/loop0       88M   88M     0 100% /snap/core/5328
/dev/loop1       13M   13M     0 100% /snap/amazon-ssm-agent/495
/dev/xvdh        25G   45M   24G   1% /data
tmpfs            99M     0   99M   0% /run/user/1000
```

That is, you can see the 25 GB data volume mounted at `/data`.

## Example 3: Running additional provisioners

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up:

```tf
module "my_host" {
  source = "./aws_ec2_ebs_docker_host"

  hostname             = "my-docker-host"
  ssh_private_key_path = "~/.ssh/id_rsa"
  ssh_public_key_path  = "~/.ssh/id_rsa.pub"
}

resource "null_resource" "provisioners" {
  depends_on = ["module.my_host"] # wait until other provisioners within the module have finished

  connection {
    host        = "${module.my_host.public_ip}"
    user        = "${module.my_host.ssh_username}"
    private_key = "${module.my_host.ssh_private_key}"
    agent       = false
  }

  provisioner "remote-exec" {
    inline = ["echo HELLO WORLD"]
  }
}
```
