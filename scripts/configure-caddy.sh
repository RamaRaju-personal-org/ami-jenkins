#!/bin/bash

# Remove default Caddyfile
sudo rm /etc/caddy/Caddyfile

# Create new Caddyfile for Jenkins
sudo tee /etc/caddy/Caddyfile <<EOF
jenkins.yourdomain.tld {
  reverse_proxy 127.0.0.1:8080
  tls jenkins.ramaraju.cloud
}
EOF

# Restart Caddy service to apply new configuration
sudo systemctl restart caddy
