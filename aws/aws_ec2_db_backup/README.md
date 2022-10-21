# aws_ec2_pg_database

**Pre-requisites :-**

1. The database should be created on ec2 instance and all the configured things have been done properly without using RDS.
2. Create an image from the database named **`any_name_of_your_choice`**. Note that this same name should be further used as a variable as well.

**Goal :-**

This module helps in taking with automated backup of the database on destroying so that when it is spun up again with the latest image can be obtained and the database can be initialized from that checkpoint onwards helping in preventing data loss & many redundant copies.

**Main features :-**

- Automated backups on destroy.
- Automated backups at regular interval.
- Automatic database creation from checkpoint.

**Resources used :-**

- EBS Snapshot
- AWS AMI
- AWS IAM ROLE
