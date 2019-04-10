# aws_internet_vpc

Creates an [AWS Virtual Private Cloud (VPC)](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html), with an [Internet Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html), enabling access to/from the outside world. Note that you still need to create an `aws_security_group` with the necessary `aws_security_group_rule`s to allow traffic to/from an EC2 instance, for example.

## Example

Assuming you have the [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) set up:

```tf
module "my_vpc" {
  # Available inputs: https://github.com/futurice/terraform-utils/tree/master/aws_internet_vpc#inputs
  # Check for updates: https://github.com/futurice/terraform-utils/compare/v9.3...master
  source   = "git::ssh://git@github.com/futurice/terraform-utils.git//aws_internet_vpc?ref=v9.3"
  vpc_name = "my-vpc"
}
```

<!-- terraform-docs:begin -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| tags | AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/ | map | `<map>` | no |
| vpc_name | Name given to the VPC; in addition to human-readability, can be used to fetch this VPC using a `aws_vpc` data block | string | `"terraform-default-vpc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| subnet_id | ID of the created AWS VPC subnet which e.g. EC2 machines can join |
| vpc_id | ID of the created AWS VPC which e.g. EC2 machines can join |
| vpc_name | Name tag of the VPC created |
<!-- terraform-docs:end -->
