#!/bin/sh
set -e

# Default values for environment variables
: ${TRACKING_DOMAIN:="localhost"}
: ${POSTHOG_HOST:="us.i.posthog.com"}
: ${POSTHOG_ASSETS_HOST:="us-assets.i.posthog.com"}
: ${SUBPATH:=""}
: ${CORS_ENABLED:="false"}
: ${CORS_ORIGIN:="*"}

# Generate CORS block if enabled
if [ "${CORS_ENABLED}" = "true" ]; then
    CORS_BLOCK="# CORS configuration
	header {
		Access-Control-Allow-Origin ${CORS_ORIGIN}
		Access-Control-Allow-Methods \"GET, POST, OPTIONS\"
		Access-Control-Allow-Headers \"Content-Type, Authorization\"
		Access-Control-Allow-Credentials \"true\"
	}

	# Handle OPTIONS requests for CORS preflight
	@options {
		method OPTIONS
	}
	respond @options 204
"
else
    CORS_BLOCK=""
fi

# Export variables for envsubst
export TRACKING_DOMAIN POSTHOG_HOST POSTHOG_ASSETS_HOST SUBPATH CORS_BLOCK

# Substitute environment variables in the Caddyfile template
echo "Configuring Caddy with:"
echo "  TRACKING_DOMAIN: ${TRACKING_DOMAIN}"
echo "  POSTHOG_HOST: ${POSTHOG_HOST}"
echo "  POSTHOG_ASSETS_HOST: ${POSTHOG_ASSETS_HOST}"
echo "  SUBPATH: ${SUBPATH:-'(none)'}"
echo "  CORS_ENABLED: ${CORS_ENABLED}"
if [ "${CORS_ENABLED}" = "true" ]; then
    echo "  CORS_ORIGIN: ${CORS_ORIGIN}"
fi

envsubst < /etc/caddy/Caddyfile.template > /etc/caddy/Caddyfile

# Show the generated Caddyfile for debugging (optional)
if [ "${DEBUG}" = "true" ]; then
    echo "Generated Caddyfile:"
    cat /etc/caddy/Caddyfile
fi

# Execute the original command
exec "$@"