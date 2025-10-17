FROM caddy:2-alpine

# Install envsubst for environment variable substitution and wget for health checks
RUN apk add --no-cache gettext wget

# Copy Caddyfile template
COPY Caddyfile.template /etc/caddy/Caddyfile.template

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80 443
EXPOSE 2019

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]