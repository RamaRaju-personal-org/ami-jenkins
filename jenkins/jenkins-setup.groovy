import jenkins.model.*
import hudson.security.*

// Get Jenkins instance
def instance = Jenkins.getInstance()

// Create local user 'admin'
println "--> creating local user 'admin'"
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('admin', 'admin')
instance.setSecurityRealm(hudsonRealm)

// Set authorization strategy to FullControlOnceLoggedInAuthorizationStrategy
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

// Save the state
instance.save()

// Bypass the Jenkins setup wizard
println "--> disabling setup wizard"
def jenkins = Jenkins.instance
jenkins.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
jenkins.save()
