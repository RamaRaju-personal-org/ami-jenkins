#!/bin/bash


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




echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                                                                                                         |"
echo "|                                                               INSTALL CADDY                                                             |"
echo "|                                                                                                                                         |"
echo "+-----------------------------------------------------------------------------------------------------------------------------------------+"

# Caddy(stable) installation docs: https://caddyserver.com/docs/install#debian-ubuntu-raspbian

# Install and configure keyring for caddy stable release:
sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo \
  gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee \
  /etc/apt/sources.list.d/caddy-stable.list

# Install caddy:
sudo apt-get update && sudo apt-get install caddy -y

# Check the status of Caddy service
sudo systemctl --full status caddy

# Check Caddy version
echo "Caddy $(caddy --version)"

# Enable Caddy service
sudo systemctl enable caddy

# Remove default Caddyfile
sudo rm /etc/caddy/Caddyfile

# Create new Caddyfile for Jenkins
sudo tee /etc/caddy/Caddyfile <<EOF
jenkins.ramaraju.cloud {
  reverse_proxy 127.0.0.1:8080
  tls jenkins.ramaraju.cloud
}
EOF

# Restart Caddy service to apply new configuration
sudo systemctl restart caddy

# Enable Caddy service
sudo systemctl enable caddy
