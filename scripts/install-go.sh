#!/bin/bash

# Variables
GO_VERSION="1.21.4"
GO_TAR_FILE="go${GO_VERSION}.linux-amd64.tar.gz"
GO_DOWNLOAD_URL="https://golang.org/dl/${GO_TAR_FILE}"

# Update and install necessary packages
sudo apt update -y
sudo apt install -y wget

# Download and install Go
wget ${GO_DOWNLOAD_URL}
sudo tar -C /usr/local -xzf ${GO_TAR_FILE}

# Set up Go environment variables
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
source ~/.profile

# Verify Go installation
go version

# Clean up
rm ${GO_TAR_FILE}

# placing jcasc.yml file in /var/lib/jenkins/config directory for goloang configuration
sudo mkdir /var/lib/jenkins/config
cp ../jenkins/jcasc.yml /var/lib/jenkins/config/go-lang-config.yml

