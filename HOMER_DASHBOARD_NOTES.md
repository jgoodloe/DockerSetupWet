# Homer Dashboard Update Notes

## 📝 Important: Update Dashboard When Adding Services

When you add new services to `docker-compose.yml`, remember to update the Homer dashboard configuration to include links to those services.

## 📍 Dashboard Configuration Location

The Homer dashboard configuration is located at:
```
homer/assets/config.yml
```

## 🔧 How to Add a New Service to Homer

1. **Open the configuration file:**
   ```bash
   nano homer/assets/config.yml
   ```

2. **Add your service to the appropriate category** (or create a new category):
   ```yaml
   - name: "Your Service Name"
     logo: "assets/icons/your-service-icon.png"
     subtitle: "Service Description"
     url: "http://localhost:PORT"
     target: "_blank"
   ```

3. **Add the service icon** (if available):
   - Place icon file in: `homer/assets/icons/`
   - Supported formats: PNG, SVG, JPG
   - Recommended size: 128x128px or 256x256px

4. **Restart the Homer container:**
   ```bash
   docker compose restart homer
   ```

## 📦 Service Categories

Current categories in the dashboard:
- **System Management**: Portainer, NGINX Proxy Manager, FileBrowser
- **Monitoring**: Grafana, Prometheus, Uptime Kuma, cAdvisor, Loki
- **Network & Security**: WireGuard, Fail2Ban, CrowdSec, Falco
- **Development Tools**: code-server, n8n
- **Utilities**: Homer, OCSP Service, Watchtower

## 🎨 Customization Options

### Icons
- Use Font Awesome icons: `icon: "fas fa-server"`
- Use custom logos: `logo: "assets/icons/custom.png"`
- Find Font Awesome icons: https://fontawesome.com/search

### Service Types
Some services support special types for enhanced display:
- `type: "Portainer"` - Shows Portainer API stats
- `type: "UptimeKuma"` - Shows Uptime Kuma status
- `type: "PiHole"` - Shows Pi-hole statistics

### Tags
Add tags to services for filtering:
```yaml
tag: "dev"  # or "prod", "monitoring", etc.
```

## 🔗 Finding Service URLs

To find the correct URL for a service:
1. Check `docker-compose.yml` for the port mapping
2. Use the format: `http://localhost:PORT` (or your server IP)
3. For services behind NPM, use your domain name

## 📋 Checklist for New Services

- [ ] Service added to `docker-compose.yml`
- [ ] Service entry added to `homer/assets/config.yml`
- [ ] Icon added to `homer/assets/icons/` (if available)
- [ ] Homer container restarted
- [ ] Dashboard updated and tested

## 🎯 Quick Reference: Service Ports

| Service | Port | URL |
|---------|------|-----|
| NGINX Proxy Manager | 81 | http://localhost:81 |
| Portainer | 9443 | http://localhost:9443 |
| Grafana | 3000 | http://localhost:3000 |
| Prometheus | 9091 | http://localhost:9091 |
| Uptime Kuma | 3001 | http://localhost:3001 |
| cAdvisor | 8081 | http://localhost:8081 |
| Loki | 3100 | http://localhost:3100 |
| Homer | 8080 | http://localhost:8080 |
| n8n | 5678 | http://localhost:5678 |
| code-server | 8080 | http://localhost:8080 |
| WireGuard | 51821 | http://localhost:51821 |
| OCSP | 8678 | http://localhost:8678 |

## 💡 Pro Tips

1. **Use environment variables** in URLs if you have multiple environments
2. **Group related services** in the same category
3. **Add health check URLs** for services that support it
4. **Keep icons consistent** in style and size
5. **Test all links** after updating the configuration

---

**Remember**: Always update the Homer dashboard when adding new services to maintain a complete service catalog!

