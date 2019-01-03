FROM jenkinsci/blueocean

# Copy the groovy script that will create our jenkins user
COPY security.groovy /usr/share/jenkins/ref/init.groovy.d/security.groovy

# Set the number of executors on master to 0 (we don't want anyhting running on master)
RUN echo "import jenkins.model.*" > /usr/share/jenkins/ref/init.groovy.d/executors.groovy && \
    echo "Jenkins.instance.setNumExecutors(0)" >> /usr/share/jenkins/ref/init.groovy.d/executors.groovy

# Install our baseline plugins
RUN /usr/local/bin/install-plugins.sh ec2

COPY credentials.groovy /credentials.groovy
COPY ec2-plugin-configuration.groovy /ec2-plugin-configuration.groovy
COPY setup.groovy /setup.groovy

# Allows us to skip the installation wizard
RUN echo ${JENKINS_VERSION} > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state \
    && echo ${JENKINS_VERSION} > /usr/share/jenkins/ref/jenkins.install.InstallUtil.lastExecVersion
