# aws_internet_vpc

Creates an [AWS Virtual Private Cloud (VPC)](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html), with an [Internet Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html), enabling access to/from the outside world. Note that you still need to create an `aws_security_group` with the necessary `aws_security_group_rule`s to allow traffic to/from an EC2 instance, for example.

## Example

```tf
module "vpc" {
  source   = "github.com/futurice/terraform-utils/aws_internet_vpc"
  vpc_name = "my-vpc"
}
```
