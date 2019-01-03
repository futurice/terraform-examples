#!/usr/bin/env bash

set -xe

JENKINS_USERNAME=$1
JENKINS_USER_PASSWORD=$2
JENKINS_WORKSPACE_DIR="/data/jenkins/workspace"

if [ -z "${JENKINS_USERNAME}" -o -z "${JENKINS_USER_PASSWORD}" ]; then
    >&2 echo "usage: provision-jenkins.sh JENKINS_USERNAME JENKINS_USER_PASSWORD"
    exit 1
fi

# Wait for Jenkins to be ready…
docker-compose exec jenkins_master bash -c "while [ ! -f /var/jenkins_home/war/WEB-INF/jenkins-cli.jar ]; do sleep 5; done" # … first by making sure the required jar file is present…
docker-compose exec jenkins_master bash -c "until \$(curl --output /dev/null --silent --head --fail http://${JENKINS_USERNAME}:${JENKINS_USER_PASSWORD}@localhost:8080); do sleep 5; done" # … then by making sure Jenkins responds to requests

# Run the provisioning scripts
docker-compose exec jenkins_master bash -c "cat /setup.groovy | java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://${JENKINS_USERNAME}:${JENKINS_USER_PASSWORD}@localhost:8080 groovy =" # for unkown reasons, this just won't work as an init script and would write an empty string as key
docker-compose exec jenkins_master bash -c "cat /credentials.groovy | java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://${JENKINS_USERNAME}:${JENKINS_USER_PASSWORD}@localhost:8080 groovy ="
docker-compose exec jenkins_master bash -c "cat /ec2-plugin-configuration.groovy | java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://${JENKINS_USERNAME}:${JENKINS_USER_PASSWORD}@localhost:8080 groovy ="
