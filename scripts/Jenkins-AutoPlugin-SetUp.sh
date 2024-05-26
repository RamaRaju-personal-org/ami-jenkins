#!/bin/bash

# Define the list of plugins
PLUGINS_LIST="ant:latest
antisamy-markup-formatter:latest
build-timeout:latest
cloudbees-folder:latest
command-launcher:latest
configuration-as-code:latest
configuration-as-code-groovy:latest
credentials:latest
credentials-binding:latest
display-url-api:latest
docker-plugin:latest
docker-commons:latest
docker-workflow:latest
docker-java-api:latest
email-ext:latest
git:latest
github:latest
github-api:latest
github-branch-source:latest
gradle:latest
job-dsl:latest
ldap:latest
mailer:latest
matrix-auth:latest
matrix-project:latest
nodejs:latest
okhttp-api:latest
pam-auth:latest
pipeline-github-lib:latest
pipeline-stage-view:latest
plain-credentials:latest
plugin-util-api:latest
semantic-versioning-plugin:latest
ssh-slaves:latest
timestamper:latest
workflow-aggregator:latest
ws-cleanup:latest
go:latest
"

# Write the list of plugins to plugins.txt
echo "Writing the list of plugins to plugins.txt..."
echo "$PLUGINS_LIST" > /tmp/plugins.txt

# Install jenkins-plugin-manager
echo "Installing jenkins-plugin-manager..."
wget --quiet https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.13/jenkins-plugin-manager-2.12.13.jar

# Install plugins using jenkins-plugin-manager tool
echo "Installing plugins..."
sudo java -jar ./jenkins-plugin-manager-2.12.13.jar --war /usr/share/java/jenkins.war \
  --plugin-download-directory /var/lib/jenkins/plugins --plugin-file /tmp/plugins.txt

echo "Plugins installed successfully."



# Configure JAVA_OPTS to disable setup wizard
sudo mkdir -p /etc/systemd/system/jenkins.service.d/
{
  echo "[Service]"
  echo "Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=/var/lib/jenkins/jcasc.yaml\""
} | sudo tee /etc/systemd/system/jenkins.service.d/override.conf

echo "Restarting Jenkins service with JCasC..."
sudo systemctl daemon-reload
sudo systemctl stop jenkins
sudo systemctl start jenkins
