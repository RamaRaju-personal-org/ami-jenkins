#!/bin/bash
# Set debconf to run in non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# # Define the list of plugins
# PLUGINS_LIST=(
#   "ant:latest"
#   "antisamy-markup-formatter:latest"
#   "build-timeout:latest"
#   "cloudbees-folder:latest"
#   "command-launcher:latest"
#   "configuration-as-code:latest"
#   "configuration-as-code-groovy:latest"
#   "credentials:latest"
#   "credentials-binding:latest"
#   "display-url-api:latest"
#   "docker-plugin:latest"
#   "docker-commons:latest"
#   "docker-workflow:latest"
#   "docker-java-api:latest"
#   "email-ext:latest"
#   "git:latest"
#   "github:latest"
#   "github-api:latest"
#   "github-branch-source:latest"
#   "gradle:latest"
#   "job-dsl:latest"
#   "ldap:latest"
#   "mailer:latest"
#   "matrix-auth:latest"
#   "matrix-project:latest"
#   "nodejs:latest"
#   "okhttp-api:latest"
#   "pam-auth:latest"
#   "pipeline-github-lib:latest"
#   "pipeline-stage-view:latest"
#   "plain-credentials:latest"
#   "plugin-util-api:latest"
#   "semantic-versioning-plugin:latest"
#   "ssh-slaves:latest"
#   "timestamper:latest"
#   "workflow-aggregator:latest"
#   "ws-cleanup:latest"
#   "go:latest"
#   "groovy:latest"
# )

# # Write the list of plugins to plugins.txt
# echo "Writing the list of plugins to plugins.txt..."
# for plugin in "${PLUGINS_LIST[@]}"; do
#   echo "$plugin"
# done > /tmp/plugins.txt

# Install jenkins-plugin-manager
echo "Installing jenkins-plugin-manager..."
wget --quiet https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.13/jenkins-plugin-manager-2.12.13.jar

# Install plugins using jenkins-plugin-manager tool
echo "Installing plugins..."
sudo java -jar ./jenkins-plugin-manager-2.12.13.jar --war /usr/share/java/jenkins.war \
  --plugin-download-directory /var/lib/jenkins/plugins --plugin-file /home/ubuntu/plugins.txt

echo "Plugins installed successfully."


# Move Jenkins config file to Jenkins home
sudo cp /home/ubuntu/jenkins.yaml /var/lib/jenkins/

# Make jenkins user and group owner of jenkins.yaml file
sudo chown jenkins:jenkins /var/lib/jenkins/jenkins.yaml

# Update users and group permissions to ⁠ jenkins ⁠ for all installed plugins:
cd /var/lib/jenkins/plugins/ || exit
sudo chown jenkins:jenkins ./*

# Disable the setup wizard by applying JCasC
echo "Configuring JAVA_OPTS to disable setup wizard and apply JCasC configuration"
sudo mkdir -p /etc/systemd/system/jenkins.service.d/
{
  echo "[Service]"
  echo "Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=true -Dcasc.jenkins.config=/var/lib/jenkins/Jcasc.yaml\""
} | sudo tee /etc/systemd/system/jenkins.service.d/override.conf

# Restart Jenkins to apply JCasC configuration
echo "Restarting Jenkins service to apply JCasC configuration"
sudo systemctl daemon-reload
sudo systemctl restart jenkins
sudo systemctl enable jenkins
