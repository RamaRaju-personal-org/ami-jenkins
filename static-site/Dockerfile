FROM caddy:2.4.1
COPY Caddyfile /etc/caddy/Caddyfile
COPY index.html /usr/share/caddy
WORKDIR /srv
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
