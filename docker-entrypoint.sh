#!/bin/sh
set -e

# Default values for environment variables
: ${TRACKING_DOMAIN:="localhost"}
: ${POSTHOG_HOST:="us.i.posthog.com"}
: ${POSTHOG_ASSETS_HOST:="us-assets.i.posthog.com"}
: ${SUBPATH:=""}
: ${CORS_ORIGIN:="https://${TRACKING_DOMAIN}"}
: ${USE_HTTPS:="true"}

# Export variables for envsubst
export TRACKING_DOMAIN POSTHOG_HOST POSTHOG_ASSETS_HOST SUBPATH CORS_ORIGIN USE_HTTPS

# Substitute environment variables in the Caddyfile template
echo "Configuring Caddy with:"
echo "  TRACKING_DOMAIN: ${TRACKING_DOMAIN}"
echo "  POSTHOG_HOST: ${POSTHOG_HOST}"
echo "  POSTHOG_ASSETS_HOST: ${POSTHOG_ASSETS_HOST}"
echo "  SUBPATH: ${SUBPATH:-'(none)'}"
echo "  CORS_ORIGIN: ${CORS_ORIGIN}"

envsubst < /etc/caddy/Caddyfile.template > /etc/caddy/Caddyfile

# Show the generated Caddyfile for debugging (optional)
if [ "${DEBUG}" = "true" ]; then
    echo "Generated Caddyfile:"
    cat /etc/caddy/Caddyfile
fi

# Execute the original command
exec "$@"