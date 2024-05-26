#!/bin/bash

# Ensure the script is run as root or using sudo
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root or using sudo."
  exit 1
fi

# Variables
JENKINS_URL="http://localhost:8080"
ADMIN_USER="admin"
JENKINS_PASSWORD_FILE="/var/lib/jenkins/secrets/initialAdminPassword"
JENKINS_PLUGINS_DIR="/var/lib/jenkins/plugins"
JENKINS_HOME="/var/lib/jenkins"
JAVA_OPTS_FILE="/etc/default/jenkins"

# Read Jenkins initial admin password
if [ -f "$JENKINS_PASSWORD_FILE" ]; then
  ADMIN_PASSWORD=$(sudo cat "$JENKINS_PASSWORD_FILE")
else
  echo "Jenkins initial admin password file not found at $JENKINS_PASSWORD_FILE"
  exit 1
fi

# Wait for Jenkins to be fully up and running
echo "Waiting for Jenkins to start..."
until curl -sSf "$JENKINS_URL/login" > /dev/null; do
  sleep 10
done
echo "Jenkins is up and running."

# Install jenkins-plugin-manager
echo "Installing jenkins-plugin-manager..."
wget --quiet https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.13/jenkins-plugin-manager-2.12.13.jar

# Define plugins to be installed
PLUGINS=(
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
)

# Create a plugins.txt file
echo "Creating plugins.txt file..."
for plugin in "${PLUGINS[@]}"; do
  echo "$plugin" >> plugins.txt
done

# Install plugins using jenkins-plugin-manager tool
echo "Installing plugins..."
sudo java -jar ./jenkins-plugin-manager-2.12.13.jar --war /usr/share/java/jenkins.war \
  --plugin-download-directory /var/lib/jenkins/plugins --plugin-file plugins.txt

# Update users and group permissions to `jenkins` for all installed plugins
echo "Updating permissions for installed plugins..."
cd /var/lib/jenkins/plugins/ || exit
sudo chown jenkins:jenkins ./*

# Move Jenkins files to Jenkins home
echo "Moving Jenkins files to Jenkins home..."
sudo mv /tmp/jenkins_home/* "$JENKINS_HOME/"
sudo chown -R jenkins:jenkins "$JENKINS_HOME/"

# Configure JAVA_OPTS to disable setup wizard
echo "Configuring JAVA_OPTS to disable setup wizard..."
if grep -q "JAVA_OPTS" "$JAVA_OPTS_FILE"; then
  sed -i 's/JAVA_OPTS=\"/JAVA_OPTS=\"-Djenkins.install.runSetupWizard=false /' "$JAVA_OPTS_FILE"
else
  echo 'JAVA_OPTS="-Djenkins.install.runSetupWizard=false"' >> "$JAVA_OPTS_FILE"
fi

# Restart Jenkins to apply changes
echo "Restarting Jenkins..."
systemctl restart jenkins

echo "Jenkins setup is complete with recommended plugins installed, permissions updated, and setup wizard disabled."
