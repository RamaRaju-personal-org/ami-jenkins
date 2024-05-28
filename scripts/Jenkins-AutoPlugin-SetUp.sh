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
sudo mv /home/ubuntu/jcasc.yml  /var/lib/jenkins/jcasc.yml
sudo mv /home/ubuntu/jenkins-setup.groovy /var/lib/jenkins/jenkins-setup.groovy

# Update file ownership
echo "Updating file ownership"
cd /var/lib/jenkins/ || exit
sudo chown jenkins:jenkins ./jcasc.yml ./*.groovy

# Configure JAVA_OPTS to disable setup wizard and apply JCasC configuration
echo "Configuring JAVA_OPTS to disable setup wizard and apply JCasC configuration"
sudo mkdir -p /etc/systemd/system/jenkins.service.d/
{
  echo "[Service]"
  echo "Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=/var/lib/jenkins/jcasc.yml\""
} | sudo tee /etc/systemd/system/jenkins.service.d/override.conf

# Restart Jenkins to apply JCasC configuration
echo "Restarting Jenkins service to apply JCasC configuration"
sudo systemctl daemon-reload
sudo systemctl restart jenkins
sleep 60  # Wait for Jenkins to fully restart

# Download Jenkins CLI
echo "Downloading Jenkins CLI..."
wget -q http://localhost:8080/jnlpJars/jenkins-cli.jar -P /home/ubuntu/

# Run the Groovy script to create user and bypass setup wizard
echo "Running Groovy script to create user and bypass setup wizard"
sudo java -jar /home/ubuntu/jenkins-cli.jar -auth admin:admin -s http://localhost:8080/ groovy = /var/lib/jenkins/jenkins-setup.groovy

# Restart Jenkins service again to ensure changes are applied
echo "Restarting Jenkins service again to ensure changes are applied"
sudo systemctl restart jenkins
sudo systemctl enable jenkins
