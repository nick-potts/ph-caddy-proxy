FROM caddy:2-alpine

# Install envsubst for environment variable substitution
RUN apk add --no-cache gettext

# Copy Caddyfile template
COPY Caddyfile.template /etc/caddy/Caddyfile.template

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80 443
EXPOSE 2019

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]