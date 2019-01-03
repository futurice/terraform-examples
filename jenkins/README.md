# Jenkins Master

This module creates a [Jenkins](https://jenkins.io/) master instance, which uses the [Amazon EC2 Plugin](https://wiki.jenkins.io/display/JENKINS/Amazon+EC2+Plugin) to create agents for itself, on demand.

## Re-provisioning considerations

This module is safe to re-provision with a simple `fiba-3x3-infra-host-reprovision` call. No extra hoops to jump through.

The only caveat is that the Jenkins jobs defined in [`create-jobs.groovy`](create-jobs.groovy) are only applied if they don't already exist. This is because otherwise every re-provisioning of the host would effectively remove and re-create all jobs, thus losing their build history for example.
