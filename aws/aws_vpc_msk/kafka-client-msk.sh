#!/bin/bash

yum update -y 

yum install python3.7 -y

yum install java-1.8.0-openjdk-devel -y

yum erase awscli -y

cd /home/ec2-user

echo "export PATH=.local/bin:$PATH" >> .bash_profile

mkdir kafka

mkdir mm

cd kafka

wget https://archive.apache.org/dist/kafka/2.2.1/kafka_2.12-2.2.1.tgz

tar -xzf kafka_2.12-2.2.1.tgz

cd /home/ec2-user

wget https://bootstrap.pypa.io/get-pip.py

su -c "python3.7 get-pip.py --user" -s /bin/sh ec2-user

su -c "/home/ec2-user/.local/bin/pip3 install boto3 --user" -s /bin/sh
ec2-user

su -c "/home/ec2-user/.local/bin/pip3 install awscli --user" -s /bin/sh
ec2-user

chown -R ec2-user ./kafka

chgrp -R ec2-user ./kafka

chown -R ec2-user ./mm

chgrp -R ec2-user ./mm