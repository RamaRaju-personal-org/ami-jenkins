#!/bin/bash

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
jenkins.ramaraju.cloud {
  reverse_proxy 127.0.0.1:8080
  tls vadapalli.j@northeastern.edu
}
EOF

# Restart Caddy service to apply new configuration
sudo systemctl restart caddy
