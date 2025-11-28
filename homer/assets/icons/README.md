# Homer Dashboard Icons

Place service icons in this directory for use in the Homer dashboard.

## Icon Requirements

- **Format**: PNG, SVG, or JPG
- **Recommended Size**: 128x128px or 256x256px
- **Naming**: Use descriptive names (e.g., `portainer.png`, `grafana.png`)

## Where to Find Icons

1. **Official Service Logos**: Check each service's official website/documentation
2. **Simple Icons**: https://simpleicons.org/
3. **Font Awesome**: Use Font Awesome icons in config instead: `icon: "fas fa-server"`
4. **Custom Icons**: Create your own or find on icon repositories

## Icon Reference

The following icons are referenced in `config.yml`:
- `portainer.png`
- `nginx-proxy-manager.png`
- `filebrowser.png`
- `grafana.png`
- `prometheus.png`
- `uptime-kuma.png`
- `cadvisor.png`
- `loki.png`
- `wireguard-icon.png`
- `fail2ban.png`
- `crowdsec.png`
- `falco.png`
- `code-server.png`
- `n8n-color.png`
- `homer.png`
- `certificate.png`
- `watchtower.png`

## Adding Icons

1. Download or create the icon file
2. Place it in this directory
3. Reference it in `config.yml` as: `logo: "assets/icons/your-icon.png"`
4. Restart Homer: `docker compose restart homer`

