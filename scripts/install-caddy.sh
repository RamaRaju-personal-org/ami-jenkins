#!/bin/bash

# Install dependencies
sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https

# Add Caddy GPG key and repository
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo apt-key add -
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee -a /etc/apt/sources.list.d/caddy-stable.list

# Update package list and install Caddy
sudo apt-get update -y
sudo apt-get install -y caddy

# Enable Caddy service
sudo systemctl enable caddy
