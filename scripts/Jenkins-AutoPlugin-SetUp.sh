#!/bin/bash

# Define the list of plugins
PLUGINS_LIST=(
  "ant:latest"
  "antisamy-markup-formatter:latest"
  "build-timeout:latest"
  "cloudbees-folder:latest"
  "command-launcher:latest"
  "configuration-as-code:latest"
  "configuration-as-code-groovy:latest"
  "credentials:latest"
  "credentials-binding:latest"
  "display-url-api:latest"
  "docker-plugin:latest"
  "docker-commons:latest"
  "docker-workflow:latest"
  "docker-java-api:latest"
  "email-ext:latest"
  "git:latest"
  "github:latest"
  "github-api:latest"
  "github-branch-source:latest"
  "gradle:latest"
  "job-dsl:latest"
  "ldap:latest"
  "mailer:latest"
  "matrix-auth:latest"
  "matrix-project:latest"
  "nodejs:latest"
  "okhttp-api:latest"
  "pam-auth:latest"
  "pipeline-github-lib:latest"
  "pipeline-stage-view:latest"
  "plain-credentials:latest"
  "plugin-util-api:latest"
  "semantic-versioning-plugin:latest"
  "ssh-slaves:latest"
  "timestamper:latest"
  "workflow-aggregator:latest"
  "ws-cleanup:latest"
  "go:latest"
  "groovy:latest"
)

# Write the list of plugins to plugins.txt
echo "Writing the list of plugins to plugins.txt..."
for plugin in "${PLUGINS_LIST[@]}"; do
  echo "$plugin"
done > /tmp/plugins.txt

# Install jenkins-plugin-manager
echo "Installing jenkins-plugin-manager..."
wget --quiet https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.13/jenkins-plugin-manager-2.12.13.jar

# Install plugins using jenkins-plugin-manager tool
echo "Installing plugins..."
sudo java -jar ./jenkins-plugin-manager-2.12.13.jar --war /usr/share/java/jenkins.war \
  --plugin-download-directory /var/lib/jenkins/plugins --plugin-file /tmp/plugins.txt

# Restart Jenkins
sudo systemctl restart jenkins
echo "Plugins installed successfully."

# Move JCasC YAML and Groovy script files
echo "Moving files"
sudo mv /home/ubuntu/Jcasc.yml  /var/lib/jenkins/Jcasc.yml
sudo mv /home/ubuntu/jenkins-setup.groovy /var/lib/jenkins/jenkins-setup.groovy

# Update file ownership
echo "Updating file ownership"
cd /var/lib/jenkins/ || exit
sudo chown jenkins:jenkins ./Jcasc.yml ./*.groovy

# Configure JAVA_OPTS to disable setup wizard and apply JCasC configuration
echo "Configuring JAVA_OPTS to disable setup wizard and apply JCasC configuration"
sudo mkdir -p /etc/systemd/system/jenkins.service.d/
{
  echo "[Service]"
  echo "Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=/var/lib/jenkins/Jcasc.yml\""
} | sudo tee /etc/systemd/system/jenkins.service.d/override.conf

# Restart Jenkins to apply JCasC configuration
echo "Restarting Jenkins service to apply JCasC configuration"
sudo systemctl daemon-reload
sudo systemctl restart jenkins
sleep 60  # Wait for Jenkins to fully restart

# Download Jenkins CLI
echo "Downloading Jenkins CLI..."
wget -q http://localhost:8080/jnlpJars/jenkins-cli.jar -P /home/ubuntu/

# # Run the Groovy script to create user and bypass setup wizard
# echo "Running Groovy script to create user and bypass setup wizard"
# sudo java -jar /home/ubuntu/jenkins-cli.jar -auth admin:admin -s http://localhost:8080/ groovy = /var/lib/jenkins/jenkins-setup.groovy

# # Restart Jenkins service again to ensure changes are applied
# echo "Restarting Jenkins service again to ensure changes are applied"
# sudo systemctl restart jenkins
# sudo systemctl enable jenkins


# Create seed job to run the Groovy script
echo "Creating seed job to run Groovy script"
cat <<EOF > /var/lib/jenkins/jobs/Run Groovy Script/config.xml
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.39">
  <actions>
    <org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobAction plugin="pipeline-model-definition@1.3.8"/>
    <org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobPropertyTrackerAction plugin="pipeline-model-definition@1.3.8">
      <jobProperties/>
      <triggers/>
      <parameters/>
      <options/>
    </org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobPropertyTrackerAction>
  </actions>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.80">
    <script>
    pipeline {
      agent any
      stages {
        stage('Run Groovy Script') {
          steps {
            script {
              def groovyScript = new File('/var/lib/jenkins/jenkins-setup.groovy')
              evaluate(groovyScript)
            }
          }
        }
      }
    }
    </script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

# Trigger the seed job
echo "Triggering the seed job"
java -jar /home/ubuntu/jenkins-cli.jar -auth admin:admin -s http://localhost:8080/ build "Run Groovy Script"

# Restart Jenkins service again to ensure changes are applied
echo "Restarting Jenkins service again to ensure changes are applied"
sudo systemctl restart jenkins
sudo systemctl enable jenkins
