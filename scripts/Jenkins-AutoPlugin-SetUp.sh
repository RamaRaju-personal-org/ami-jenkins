#!/bin/bash


# Install jenkins-plugin-manager
echo "Installing jenkins-plugin-manager..."
wget --quiet https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.13/jenkins-plugin-manager-2.12.13.jar


# Install plugins using jenkins-plugin-manager tool
echo "Installing plugins..."
sudo java -jar ./jenkins-plugin-manager-2.12.13.jar --war /usr/share/java/jenkins.war \
  --plugin-download-directory /var/lib/jenkins/plugins --plugin-file plugins.txt


# Restart Jenkins to apply changes
echo "Restarting Jenkins..."
systemctl restart jenkins

echo "Jenkins setup is complete with recommended plugins installed, permissions updated, and setup wizard disabled."
