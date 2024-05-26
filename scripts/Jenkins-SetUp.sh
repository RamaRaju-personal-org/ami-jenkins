#!/bin/bash

# Jenkins server details
JENKINS_URL="http://localhost:8080"
ADMIN_USER="admin"

# Check if the script is run as root or using sudo
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root or using sudo."
  exit 1
fi

# Read Jenkins initial admin password
JENKINS_PASSWORD_FILE="/var/lib/jenkins/secrets/initialAdminPassword"

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

# Install Jenkins CLI
echo "Downloading Jenkins CLI..."
curl -O "$JENKINS_URL/jnlpJars/jenkins-cli.jar"

# Define recommended plugins
RECOMMENDED_PLUGINS=(
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

# Install recommended plugins
echo "Installing recommended plugins..."
for plugin in "${RECOMMENDED_PLUGINS[@]}"; do
  java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$ADMIN_USER:$ADMIN_PASSWORD" install-plugin "$plugin" -deploy
done

# Restart Jenkins to apply plugin installations
echo "Restarting Jenkins..."
java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$ADMIN_USER:$ADMIN_PASSWORD" safe-restart

echo "Jenkins setup is complete with recommended plugins installed."
