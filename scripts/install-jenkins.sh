#!/bin/bash

# Update package list and install OpenJDK
sudo apt-get update -y
sudo apt-get install -y openjdk-11-jdk

# Add Jenkins key and repository
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# Update package list and install Jenkins
sudo apt-get update -y
sudo apt-get install -y jenkins

# Enable Jenkins service
sudo systemctl enable jenkins
