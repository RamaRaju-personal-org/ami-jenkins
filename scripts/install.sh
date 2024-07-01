#!/bin/bash

# Set debconf to run in non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# This script installs, configures and starts Jenkins on the AMI

##########################################################################
## Installing Jenkins and other dependencies

# Update package information
sudo apt-get update -y

# Install Java (Required by Jenkins) and Maven
sudo apt-get install -y openjdk-11-jdk maven

# Download the Jenkins repository key and saves it to /usr/share/keyrings/jenkins-keyring.asc,
# which is used to authenticate packages
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add the Jenkins repository to the packages sources list, specifying that packages from
# this repository should be verified using the key saved in /usr/share/keyrings/jenkins-keyring.asc.
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update the package lists to include newly available packages from the added Jenkins repository.
sudo apt-get update

# Install the Jenkins package from the newly added repository
sudo apt-get install jenkins -y

sleep 3

# Check the status of Jenkins service
sudo systemctl --full status jenkins

# Check Jenkins version
echo "Jenkins $(jenkins --version)"

#########################################################################

# install docker 
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# Install Docker:
sudo apt-get update && sudo apt-get install docker-ce -y

#If you want to avoid typing sudo whenever you run the docker command, add your username to the docker group:
sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker jenkins

##########################################################################


# Caddy(stable) installation docs: https://caddyserver.com/docs/install#debian-ubuntu-raspbian

# Install and configure keyring for caddy stable release:
sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo \
  gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee \
  /etc/apt/sources.list.d/caddy-stable.list

# Install caddy:
sudo apt-get update && sudo apt-get install caddy -y


# Enable Caddy service
sudo systemctl enable caddy


# Remove default Caddyfile
sudo rm /etc/caddy/Caddyfile

# Create new Caddyfile for Jenkins
sudo tee /etc/caddy/Caddyfile <<EOF
{
   acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
}

cicd.ramaraju.cloud {
  reverse_proxy http://127.0.0.1:8080
}
EOF

# Restart Caddy service to apply new configuration
sudo systemctl restart caddy

##########################################################################
## Installing Plugins for Jenkins

cd /home/ubuntu/

# Install Jenkins plugin manager tool to be able to install the plugins on EC2 instance
wget --quiet \
  https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.13/jenkins-plugin-manager-2.12.13.jar

# Install plugins with jenkins-plugin-manager tool:
sudo java -jar ./jenkins-plugin-manager-2.12.13.jar --war /usr/share/java/jenkins.war \
  --plugin-download-directory /var/lib/jenkins/plugins --plugin-file plugins.txt

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Move Jenkins config file to Jenkins home
sudo cp /home/ubuntu/jenkins.yaml /var/lib/jenkins/
sudo cp /home/ubuntu/plugins.txt /var/lib/jenkins/plugins/

# Copy DSL job files to Jenkins home
sudo cp /home/ubuntu/build-docker-image.groovy /var/lib/jenkins/
sudo cp /home/ubuntu/Jenkinsfile /var/lib/jenkins/Jenkinsfile

# Make jenkins user and group owner of jenkins.yaml file
sudo chown jenkins:jenkins /var/lib/jenkins/jenkins.yaml
sudo chown jenkins:jenkins /var/lib/jenkins/build-docker-image.groovy
sudo chown jenkins:jenkins /var/lib/jenkins/Jenkinsfile

# Update users and group permissions to `jenkins` for all installed plugins:
cd /var/lib/jenkins/plugins/ || exit
sudo chown jenkins:jenkins ./*

# Configure JAVA_OPTS to disable setup wizard
sudo mkdir -p /etc/systemd/system/jenkins.service.d/
{
  echo "[Service]"
  echo "Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=/var/lib/jenkins/jenkins.yaml\""
} | sudo tee /etc/systemd/system/jenkins.service.d/override.conf

# Restart jenkins service
sudo systemctl daemon-reload
sudo systemctl stop jenkins
sudo systemctl start jenkins


############################## Helm Installation ############################

sudo apt-get update
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg >/dev/null
sudo apt-get install apt-transport-https -y
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" |
  sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update && sudo apt-get install helm

# Check Helm version
echo "Helm $(helm version)"



############################## INSTALL KUBECTL & IAM AUTHENTICATOR ############################
sudo apt-get update
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl; chmod +x ./kubectl; mv ./kubectl /usr/local/bin/kubectl
curl -Lo aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.6.11/aws-iam-authenticator_0.6.11_linux_amd64
chmod +x ./aws-iam-authenticator
mv ./aws-iam-authenticator /usr/local/bin

# Check Kubectl version
echo "Kubectl $(kubectl version --client)"


# copy the config file to the jenkins container 
cd /var/lib/jenkins # on jenkins container
sudo mkdir .kube # create a .kube folder
sudo mkdir k8s_files


# on your machine copy the config.yml file to the jenkins container 
sudo cp /home/ubuntu/config.yaml /var/lib/jenkins/.kube/
sudo chown jenkins:jenkins /var/lib/jenkins/.kube/*



# check the file on the jenkins container 
ls -al .kube



##################### INSTALL ENVSUBST ##################
# envsubst installation (login as root and install)
sudo apt-get install gettext-base  -y
