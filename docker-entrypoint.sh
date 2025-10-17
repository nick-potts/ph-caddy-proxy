#!/bin/sh
set -e

# Default values for environment variables
: ${TRACKING_DOMAIN:="localhost"}
: ${POSTHOG_HOST:="us.i.posthog.com"}
: ${POSTHOG_ASSETS_HOST:="us-assets.i.posthog.com"}
: ${SSL_ENABLED:="true"}

# Configure domain with or without SSL
if [ "${SSL_ENABLED}" = "false" ]; then
    DOMAIN_CONFIG="http://${TRACKING_DOMAIN}"
else
    DOMAIN_CONFIG="${TRACKING_DOMAIN}"
fi

# Export variables for envsubst
export DOMAIN_CONFIG TRACKING_DOMAIN POSTHOG_HOST POSTHOG_ASSETS_HOST

# Substitute environment variables in the Caddyfile template
echo "Configuring Caddy with:"
echo "  TRACKING_DOMAIN: ${TRACKING_DOMAIN}"
echo "  POSTHOG_HOST: ${POSTHOG_HOST}"
echo "  POSTHOG_ASSETS_HOST: ${POSTHOG_ASSETS_HOST}"
echo "  SSL_ENABLED: ${SSL_ENABLED}"

envsubst < /etc/caddy/Caddyfile.template > /etc/caddy/Caddyfile

# Show the generated Caddyfile for debugging (optional)
if [ "${DEBUG}" = "true" ]; then
    echo "Generated Caddyfile:"
    cat /etc/caddy/Caddyfile
fi

# Execute the original command
exec "$@"