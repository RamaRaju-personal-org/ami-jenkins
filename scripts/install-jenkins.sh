#!/bin/bash

# Set non-interactive frontend
export DEBIAN_FRONTEND=noninteractive
export CHECKPOINT_DISABLE=1

echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                               INSTALL JAVA 11                                                           |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
# Update package list and install OpenJDK
sudo apt-get install -y openjdk-11-jdk
sleep 3
echo "Java $(java -version)"


echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                                INSTALL JENKINS                                                          |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
# Add Jenkins key and repository

# Jenkins setup on Debian (stable): https://pkg.jenkins.io/debian-stable/

# Debian package repository of Jenkins to automate installation and upgrade.
# To use this repository, first add the key to the system:
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc >/dev/null

# Add a Jenkins apt repository entry:
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list >/dev/null

# Install Jenkins:
sudo apt-get update && sudo apt-get install jenkins -y

sleep 3

sudo systemctl start jenkins

# Enable Jenkins service
sudo systemctl enable jenkins
sleep 3

# Check the status of Jenkins service
sudo systemctl --full status jenkins

# Check Jenkins version
echo "Jenkins $(jenkins --version)"
