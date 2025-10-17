#!/bin/sh
set -e

# Default values for environment variables
: ${TRACKING_DOMAIN:="localhost"}
: ${POSTHOG_HOST:="us.i.posthog.com"}
: ${POSTHOG_ASSETS_HOST:="us-assets.i.posthog.com"}
: ${SUBPATH:=""}
: ${CORS_ENABLED:="false"}
: ${CORS_ORIGIN:="https://${TRACKING_DOMAIN}"}
: ${SSL_ENABLED:="true"}

# Generate CORS block if enabled
if [ "${CORS_ENABLED}" = "true" ]; then
    CORS_BLOCK="header {
		Access-Control-Allow-Origin ${CORS_ORIGIN}
	}
"
else
    CORS_BLOCK=""
fi

# Generate handlers based on whether subpath is used
if [ -n "${SUBPATH}" ]; then
    # Using subpath - use handle_path to strip the prefix
    SUBPATH_HANDLERS="handle_path ${SUBPATH}/static* {
		rewrite * /static{path}
		reverse_proxy https://${POSTHOG_ASSETS_HOST}:443 {
			header_up Host ${POSTHOG_ASSETS_HOST}
			header_down -Access-Control-Allow-Origin
		}
	}

	handle_path ${SUBPATH}* {
		rewrite * {path}
		reverse_proxy https://${POSTHOG_HOST}:443 {
			header_up Host ${POSTHOG_HOST}
			header_down -Access-Control-Allow-Origin
		}
	}
"
else
    # No subpath - use the simple version
    SUBPATH_HANDLERS="handle /static {
		reverse_proxy https://${POSTHOG_ASSETS_HOST}:443 {
			header_up Host ${POSTHOG_ASSETS_HOST}
			header_down -Access-Control-Allow-Origin
		}
	}

	handle {
		reverse_proxy https://${POSTHOG_HOST}:443 {
			header_up Host ${POSTHOG_HOST}
			header_down -Access-Control-Allow-Origin
		}
	}
"
fi

# Configure domain with or without SSL
if [ "${SSL_ENABLED}" = "false" ]; then
    DOMAIN_CONFIG="http://${TRACKING_DOMAIN}"
else
    DOMAIN_CONFIG="${TRACKING_DOMAIN}"
fi

# Export variables for envsubst
export DOMAIN_CONFIG TRACKING_DOMAIN POSTHOG_HOST POSTHOG_ASSETS_HOST SUBPATH CORS_BLOCK SUBPATH_HANDLERS

# Substitute environment variables in the Caddyfile template
echo "Configuring Caddy with:"
echo "  TRACKING_DOMAIN: ${TRACKING_DOMAIN}"
echo "  POSTHOG_HOST: ${POSTHOG_HOST}"
echo "  POSTHOG_ASSETS_HOST: ${POSTHOG_ASSETS_HOST}"
echo "  SUBPATH: ${SUBPATH:-'(none)'}"
echo "  SSL_ENABLED: ${SSL_ENABLED}"
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