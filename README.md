# PostHog Caddy Reverse Proxy

A configurable Caddy-based reverse proxy for PostHog analytics with Docker support and automatic publishing to GitHub Container Registry.

## Features

- 🚀 Reverse proxy for PostHog analytics
- 🔧 Environment variable configuration
- 🐳 Docker and Docker Compose support
- 📦 Automatic multi-platform builds (amd64/arm64)
- 🔄 GitHub Actions CI/CD pipeline
- 🔐 SSL/TLS support via Caddy
- 📊 Support for both US and EU PostHog regions
- 🌐 Optional CORS configuration

## Quick Start

### Using Docker Compose (Recommended)

1. Clone this repository:
```bash
git clone https://github.com/yourusername/ph-caddy-proxy.git
cd ph-caddy-proxy
```

2. Copy the example environment file:
```bash
cp .env.example .env
```

3. Edit `.env` with your configuration:
```bash
nano .env
```

4. Start the proxy:
```bash
docker-compose up -d
```

### Using Docker Run

```bash
docker run -d \
  --name ph-caddy-proxy \
  -p 80:80 \
  -p 443:443 \
  -e TRACKING_DOMAIN=tracking.example.com \
  -e POSTHOG_HOST=us.i.posthog.com \
  -e POSTHOG_ASSETS_HOST=us-assets.i.posthog.com \
  -e SSL_ENABLED=true \
  -v caddy_data:/data \
  -v caddy_config:/config \
  ghcr.io/yourusername/ph-caddy-proxy:latest
```

### Using Pre-built Image from GitHub Packages

```bash
docker pull ghcr.io/yourusername/ph-caddy-proxy:latest
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `TRACKING_DOMAIN` | Your tracking domain (e.g., tracking.example.com) | localhost |
| `POSTHOG_HOST` | PostHog API host | us.i.posthog.com |
| `POSTHOG_ASSETS_HOST` | PostHog assets host | us-assets.i.posthog.com |
| `SUBPATH` | Optional subpath for the proxy (e.g., /phproxy) | (empty) |
| `SSL_ENABLED` | Enable HTTPS/SSL (set to false for local dev or behind proxy) | true |
| `CORS_ENABLED` | Enable CORS headers | false |
| `CORS_ORIGIN` | CORS allowed origin (when CORS_ENABLED=true) | https://${TRACKING_DOMAIN} |
| `DEBUG` | Enable debug mode to see generated Caddyfile | false |

### Region Configuration

#### US Region (Default)
```bash
POSTHOG_HOST=us.i.posthog.com
POSTHOG_ASSETS_HOST=us-assets.i.posthog.com
```

#### EU Region
```bash
POSTHOG_HOST=eu.i.posthog.com
POSTHOG_ASSETS_HOST=eu-assets.i.posthog.com
```

## PostHog JavaScript Integration

Once your proxy is running, update your PostHog JavaScript snippet:

```html
<script>
  !function(t,e){var o,n,p,r;e.__SV||(window.posthog=e,e._i=[],e.init=function(i,s,a){function g(t,e){var o=e.split(".");2==o.length&&(t=t[o[0]],e=o[1]),t[e]=function(){t.push([e].concat(Array.prototype.slice.call(arguments,0)))}}(p=t.createElement("script")).type="text/javascript",p.crossOrigin="anonymous",p.async=!0,p.src=s.api_host+"/static/array.js",(r=t.getElementsByTagName("script")[0]).parentNode.insertBefore(p,r);var u=e;for(void 0!==a?u=e[a]=[]:a="posthog",u.people=u.people||[],u.toString=function(t){var e="posthog";return"posthog"!==a&&(e+="."+a),t||(e+=" (stub)"),e},u.people.toString=function(){return u.toString(1)+".people (stub)"},o="capture identify alias people.set people.set_once set_config register register_once unregister opt_out_capturing has_opted_out_capturing opt_in_capturing reset isFeatureEnabled onFeatureFlags getFeatureFlag getFeatureFlagPayload reloadFeatureFlags group updateEarlyAccessFeatureEnrollment getEarlyAccessFeatures getActiveMatchingSurveys getSurveys getNextSurveyStep onSessionId".split(" "),n=0;n<o.length;n++)g(u,o[n]);e._i.push([i,s,a])},e.__SV=1)}(document,window.posthog||[]);
  posthog.init('YOUR_POSTHOG_PROJECT_API_KEY', {
    api_host: 'https://tracking.example.com',  // Your tracking domain
    ui_host: 'https://us.posthog.com'          // or https://eu.posthog.com for EU
  })
</script>
```

## Using with Subpaths

If you want to proxy PostHog through a subpath (e.g., `https://yourdomain.com/phproxy`):

1. Set the `SUBPATH` environment variable:
```bash
SUBPATH=/phproxy
```

2. Update your PostHog configuration:
```javascript
posthog.init('YOUR_PROJECT_API_KEY', {
    api_host: 'https://yourdomain.com/phproxy',
    ui_host: 'https://us.posthog.com'
})
```

## Disabling SSL (For Local Development)

By default, SSL is enabled and Caddy will automatically provision certificates. To disable SSL for local development or when running behind another SSL proxy:

```bash
SSL_ENABLED=false
```

This will configure Caddy to serve HTTP only on port 80.

## Enabling CORS (Optional)

By default, CORS is disabled to allow unrestricted access. If you need to restrict which domains can use your proxy:

1. Set environment variables:
```bash
CORS_ENABLED=true
CORS_ORIGIN=https://mysite.com  # Or use * to allow all origins
```

2. The proxy will then send appropriate CORS headers for cross-origin requests.

## Development

### Building Locally

```bash
docker build -t ph-caddy-proxy:local .
```

### Running Tests

```bash
# Start the proxy
docker-compose up -d

# Test the proxy
curl -I http://localhost/static/array.js
```

## GitHub Actions

This repository includes GitHub Actions workflows that:

1. **Build multi-platform Docker images** (linux/amd64, linux/arm64)
2. **Push to GitHub Container Registry** (ghcr.io)
3. **Tag images** with:
   - Branch names
   - Semantic versions (from git tags)
   - SHA hashes
   - `latest` for the main branch

### Triggering Builds

Builds are triggered on:
- Push to `main` or `master` branches
- Creating version tags (e.g., `v1.0.0`)
- Pull requests
- Manual workflow dispatch

## Security Considerations

- **SSL/TLS**: Caddy automatically provisions and renews SSL certificates via Let's Encrypt
- **CORS**: Optional - enable with `CORS_ENABLED=true` and configure `CORS_ORIGIN` to restrict which domains can make requests
- **Data Privacy**: This proxy doesn't store or log any analytics data - it only forwards requests

## Troubleshooting

### Enable Debug Mode

Set `DEBUG=true` to see the generated Caddyfile:

```bash
docker-compose down
DEBUG=true docker-compose up
```

### Check Logs

```bash
docker-compose logs -f caddy-proxy
```

### Common Issues

1. **Port 80/443 already in use**: Stop other services using these ports or change the port mapping in docker-compose.yml

2. **SSL certificate issues**: Ensure your domain's DNS points to the server and ports 80/443 are accessible

3. **CORS errors**: Enable CORS with `CORS_ENABLED=true` and ensure `CORS_ORIGIN` matches your application's domain

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License

MIT

## Support

For issues specific to this proxy, please open an issue in this repository.
For PostHog-related questions, visit [PostHog Documentation](https://posthog.com/docs).