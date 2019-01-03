import hudson.security.csrf.DefaultCrumbIssuer
import jenkins.model.Jenkins
import jenkins.model.JenkinsLocationConfiguration
import hudson.model.PageDecorator
import org.jenkins.ci.plugins.xframe_filter.XFrameFilterPageDecorator

// Toggle CSRF protection on
def jenkins = Jenkins.instance
if (jenkins.getCrumbIssuer() == null) {
    jenkins.setCrumbIssuer(new DefaultCrumbIssuer(true))
    jenkins.save()
}

// Set Jenkins URL
def jenkinsLocationConfiguration = JenkinsLocationConfiguration.get()
jenkinsLocationConfiguration.setUrl('https://${jenkins_url}')
jenkinsLocationConfiguration.save()
