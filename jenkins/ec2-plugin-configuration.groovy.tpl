// See https://wiki.jenkins.io/display/JENKINS/Amazon+EC2+Plugin

import com.amazonaws.services.ec2.model.InstanceType
import com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.Domain
import hudson.model.*
import hudson.plugins.ec2.AmazonEC2Cloud
import hudson.plugins.ec2.AMITypeData
import hudson.plugins.ec2.EC2Tag
import hudson.plugins.ec2.SlaveTemplate
import hudson.plugins.ec2.SpotConfiguration
import hudson.plugins.ec2.UnixData
import jenkins.model.Jenkins

def agentInitScript = '''
if [ ! -f init-script-done ]; then
  # Install java (for the jenkins agent tool)
  sudo yum install -y java-1.8.0

  # Install git
  sudo yum install -y git

  touch init-script-done
fi
'''.trim()
 
// parameters
def AgentTemplateParameters = [
  ami:                      '${agent_instance_ami}',
  associatePublicIp:        false,
  connectBySSHProcess:      false,
  connectUsingPublicIp:     false,
  customDeviceMapping:      '',
  deleteRootOnTermination:  true,
  description:              'jenkins-agent',
  ebsOptimized:             false,
  iamInstanceProfile:       '',
  idleTerminationMinutes:   '${agent_termination_minutes}',
  initScript:               agentInitScript,
  instanceCapStr:           '${agent_instances_cap}',
  jvmopts:                  '',
  labelString:              'aws.ec2.eu.central.jenkins.agent',
  launchTimeoutStr:         '',
  numExecutors:             '1',
  remoteAdmin:              '${agent_instance_username}',
  remoteFS:                 '',
  securityGroups:           '${agent_aws_security_group_id}',
  stopOnTerminate:          true,
  subnetId:                 '${agent_aws_subnet_id}',
  tags:                     new EC2Tag('Name', 'jenkins-agent'),
  tmpDir:                   '',
  type:                     '${agent_instance_type}',
  useDedicatedTenancy:      false,
  useEphemeralDevices:      true,
  usePrivateDnsName:        true,
  userData:                 '',
  zone:                     'eu-central-1a'
]
 
def AmazonEC2CloudParameters = [
  cloudName:      'EC2',
  credentialsId:  'jenkins-aws-key',
  instanceCapStr: '',
  privateKey:     '''${master_private_key}''',
  region: 'eu-central-1',
  useInstanceProfileForCredentials: false
]
 
def AWSCredentialsImplParameters = [
  id:           'jenkins-aws-key',
  description:  'Jenkins AWS IAM key',
  accessKey:    '${agent_iam_user_aws_access_key}',
  secretKey:    '${agent_iam_user_aws_secret_key}'
]
 
// https://github.com/jenkinsci/aws-credentials-plugin/blob/aws-credentials-1.23/src/main/java/com/cloudbees/jenkins/plugins/awscredentials/AWSCredentialsImpl.java
AWSCredentialsImpl aWSCredentialsImpl = new AWSCredentialsImpl(
  CredentialsScope.GLOBAL,
  AWSCredentialsImplParameters.id,
  AWSCredentialsImplParameters.accessKey,
  AWSCredentialsImplParameters.secretKey,
  AWSCredentialsImplParameters.description
)
 
// https://github.com/jenkinsci/ec2-plugin/blob/ec2-1.38/src/main/java/hudson/plugins/ec2/SlaveTemplate.java
SlaveTemplate agentTemplate = new SlaveTemplate(
  AgentTemplateParameters.ami,
  AgentTemplateParameters.zone,
  null,
  AgentTemplateParameters.securityGroups,
  AgentTemplateParameters.remoteFS,
  InstanceType.fromValue(AgentTemplateParameters.type),
  AgentTemplateParameters.ebsOptimized,
  AgentTemplateParameters.labelString,
  Node.Mode.NORMAL,
  AgentTemplateParameters.description,
  AgentTemplateParameters.initScript,
  AgentTemplateParameters.tmpDir,
  AgentTemplateParameters.userData,
  AgentTemplateParameters.numExecutors,
  AgentTemplateParameters.remoteAdmin,
  new UnixData(null, null, null, null),
  AgentTemplateParameters.jvmopts,
  AgentTemplateParameters.stopOnTerminate,
  AgentTemplateParameters.subnetId,
  [AgentTemplateParameters.tags],
  AgentTemplateParameters.idleTerminationMinutes,
  AgentTemplateParameters.usePrivateDnsName,
  AgentTemplateParameters.instanceCapStr,
  AgentTemplateParameters.iamInstanceProfile,
  AgentTemplateParameters.deleteRootOnTermination,
  AgentTemplateParameters.useEphemeralDevices,
  AgentTemplateParameters.useDedicatedTenancy,
  AgentTemplateParameters.launchTimeoutStr,
  AgentTemplateParameters.associatePublicIp,
  AgentTemplateParameters.customDeviceMapping,
  AgentTemplateParameters.connectBySSHProcess,
  AgentTemplateParameters.connectUsingPublicIp
)
 
// https://github.com/jenkinsci/ec2-plugin/blob/ec2-1.38/src/main/java/hudson/plugins/ec2/AmazonEC2Cloud.java
AmazonEC2Cloud amazonEC2Cloud = new AmazonEC2Cloud(
  AmazonEC2CloudParameters.cloudName,
  AmazonEC2CloudParameters.useInstanceProfileForCredentials,
  AmazonEC2CloudParameters.credentialsId,
  AmazonEC2CloudParameters.region,
  AmazonEC2CloudParameters.privateKey,
  AmazonEC2CloudParameters.instanceCapStr,
  [agentTemplate],
  null,
  null
)
 
// get Jenkins instance
Jenkins jenkins = Jenkins.getInstance()
 
// get credentials domain
def domain = Domain.global()
 
// get credentials store
def store = jenkins.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()
 
// add credential to store
store.addCredentials(domain, aWSCredentialsImpl)
 
// add cloud configuration to Jenkins, or replace existing one
// @see https://github.com/jenkinsci/ec2-plugin/blob/ec2-1.38/src/main/java/hudson/plugins/ec2/AmazonEC2Cloud.java#L64
def existingEc2Cloud = jenkins.clouds.getByName(AmazonEC2Cloud.CLOUD_ID_PREFIX + AmazonEC2CloudParameters.cloudName)
if (existingEc2Cloud != null) {
  jenkins.clouds.remove(existingEc2Cloud)
}
jenkins.clouds.add(amazonEC2Cloud)
 
// save current Jenkins state to disk
jenkins.save()
