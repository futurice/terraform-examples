#!groovy

import jenkins.model.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.impl.*
import org.jenkinsci.plugins.plaincredentials.impl.*
import hudson.util.Secret

// See https://github.com/hayderimran7/useful-jenkins-groovy-init-scripts/blob/master/useful_groovy_snippets.groovy

private getExistingCredentials(String id) {
  def idMatcher = CredentialsMatchers.withId(id)
  def availableCredentials =
    CredentialsProvider.lookupCredentials(
      StandardUsernameCredentials.class,
      Jenkins.getInstance(),
      hudson.security.ACL.SYSTEM,
      new SchemeRequirement('ssh')
    )

  return CredentialsMatchers.firstOrNull(
    availableCredentials,
    idMatcher
  )
}

void upsertUsernameWithPassword(String id, String username, String password, String description = '') {
  upsertCredentials(new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    id,
    description,
    username,
    password
  ))
}

void upsertPrivateKey(String id, String username, String privateKey, String description = '', String passphrase = '') {
    def keySource
    if (privateKey.startsWith('-----BEGIN')) {
      keySource = new BasicSSHUserPrivateKey.DirectEntryPrivateKeySource(privateKey)
    } else {
      keySource = new BasicSSHUserPrivateKey.FileOnMasterPrivateKeySource(privateKey)
    }
    upsertCredentials(new BasicSSHUserPrivateKey(
      CredentialsScope.GLOBAL,
      id,
      username,
      keySource,
      passphrase,
      description
    ))
}

void upsertSecretText(String id, String secret, String description = '') {
  upsertCredentials(new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    id,
    description,
    Secret.fromString(secret),
  ))
}

void upsertCredentials(BaseStandardCredentials credentials) {
  def globalDomain = Domain.global()
  def credentialsStore = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

  // Create or update the credentials in the Jenkins instance
  def existingCredentials = getExistingCredentials(credentials.id)

  if (existingCredentials != null) {
    credentialsStore.updateCredentials(
      globalDomain,
      existingCredentials,
      credentials
    )
  } else {
    credentialsStore.addCredentials(globalDomain, credentials)
  }
}

def env = System.getenv()

// Bellow are a few usage exemples
// upsertPrivateKey('secret-id', 'username', new File('/path/to/id_rsa').text)
// upsertUsernameWithPassword('secret-id', 'username', env['ENV_VAR'])
// upsertSecretText('secret-id', env['ENV_VAR'])

${instructions}
