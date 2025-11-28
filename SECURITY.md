# Security Policy

## Supported Versions

We actively support the following versions with security updates:

| Version | Supported          |
| ------- | ------------------ |
| Latest  | :white_check_mark: |
| < Latest| :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly.

### How to Report

1. **Do NOT** open a public GitHub issue for security vulnerabilities
2. Email security concerns to: [Your Email] (or create a private security advisory on GitHub)
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Resolution**: Depends on severity and complexity

### Security Best Practices

This repository includes multiple security-focused services. When deploying:

1. **Change Default Passwords**: Immediately change all default credentials
   - NGINX Proxy Manager: `admin@example.com` / `changeme`
   - Grafana: `admin` / `admin`
   - All other services with default credentials

2. **Protect Admin UIs**: Never expose admin interfaces publicly without:
   - Authentication (via NPM or service-native auth)
   - Source IP restrictions
   - TLS/HTTPS encryption

3. **Secure Docker Socket**: Limit access to `/var/run/docker.sock`
   - Portainer should use RBAC
   - Avoid exposing Portainer publicly

4. **Network Security**:
   - Use firewall rules to restrict access
   - Keep VPN (wg-easy) admin UI internal-only
   - Use NPM to reverse-proxy services instead of direct port exposure

5. **Keep Images Updated**:
   - Use Watchtower carefully (test updates first)
   - Pin critical service versions
   - Regularly scan for vulnerabilities

6. **Monitor Logs**:
   - Review CrowdSec and Fail2Ban alerts
   - Check Falco runtime security events
   - Monitor Open-AppSec WAF logs

7. **Backup Secrets**:
   - Store `.env` file securely
   - Backup encryption keys (n8n, code-server)
   - Secure Open-AppSec agent tokens

8. **Least Privilege**:
   - Run services with minimal required permissions
   - Use non-root users where possible
   - Limit container capabilities

## Known Security Considerations

### High Priority

- **Docker Socket Exposure**: Portainer and Watchtower require docker socket access - ensure they are not publicly accessible
- **Default Credentials**: All services start with default credentials - change immediately
- **Open-AppSec Token**: The agent token provides WAF management access - keep it secret

### Medium Priority

- **VPN Configuration**: WireGuard admin UI should be protected or internal-only
- **Monitoring Exposure**: Grafana and Prometheus UIs should be protected
- **Log Access**: Security tools (CrowdSec, Fail2Ban) read logs - ensure log volumes are secure

### Low Priority

- **Custom OCSP Service**: Custom-built service - review code for security
- **Falco Driver**: Kernel-level access - keep driver updated

## Security Tools Included

This stack includes several security-focused services:

- **Open-AppSec WAF**: Web application firewall protecting proxied services
- **Fail2Ban**: Intrusion prevention via IP blocking
- **CrowdSec**: Collaborative security intelligence
- **Falco**: Runtime security monitoring
- **Watchtower**: Automated container updates (use with caution)

## Disclosure Policy

We follow responsible disclosure practices:

1. Security issues are handled privately
2. Fixes are developed and tested before public disclosure
3. A security advisory is published when appropriate
4. Credit is given to reporters (if desired)

## Additional Resources

- [Open-AppSec Security Documentation](https://docs.openappsec.io)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

---

**Last Updated**: 2025-11-28

