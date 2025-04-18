---
name: cybersecurity
description: Use for security audits, vulnerability remediation, hardening configs, and secure coding patterns. Not for compliance frameworks or policy writing.
---

# Cybersecurity

## When to Use
- Security review of code, configs, or infrastructure
- Hardening a service, container, or deployment
- Investigating or remediating a vulnerability
- Implementing auth, encryption, or access control

## Workflow

### 1. Threat Model First
Before writing code, identify:
- What assets need protection (data, endpoints, keys)
- Who are the threat actors (external, internal, supply chain)
- What's the attack surface (network, API, file system, deps)

### 2. Audit
Systematic check in priority order:

**Secrets & Credentials:**
- No hardcoded secrets (grep for API keys, passwords, tokens)
- Secrets in env vars or vault, never in code/config files
- Rotate exposed credentials immediately

**Authentication & Authorization:**
- Verify auth on every endpoint, not just frontend
- Check for broken access control (IDOR, privilege escalation)
- Validate JWT/session tokens server-side

**Input Validation:**
```python
# WRONG: trusting user input
query = f"SELECT * FROM users WHERE id = {request.args['id']}"

# RIGHT: parameterized queries
cursor.execute("SELECT * FROM users WHERE id = %s", (request.args['id'],))
```

**Dependency Security:**
```bash
# Check for known vulnerabilities
npm audit --production
pip-audit
cargo audit
trivy image myapp:latest
```

**Transport & Encryption:**
- TLS 1.2+ for all connections
- HSTS headers on web services
- Encrypt sensitive data at rest (AES-256-GCM)

### 3. Harden

**Container hardening:**
```dockerfile
# Non-root user
RUN adduser -D appuser
USER appuser

# Minimal base image
FROM gcr.io/distroless/static:nonroot

# No secrets in layers
# Use multi-stage builds, copy only artifacts
```

**Network hardening:**
- Default-deny network policies
- Restrict egress to required endpoints only
- No unnecessary open ports

**Application hardening:**
```yaml
# Security headers (nginx example)
add_header X-Content-Type-Options nosniff;
add_header X-Frame-Options DENY;
add_header Content-Security-Policy "default-src 'self'";
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
```

### 4. Verify
- Run SAST/DAST scans (semgrep, bandit, gosec)
- Test auth bypass paths manually
- Verify secrets aren't in git history: `git log -p | grep -i 'password\|secret\|api.key'`
- Check container as non-root: `docker run --user 1000 myapp whoami`

## Common Pitfalls
| Pitfall | Fix |
|---------|-----|
| SQL injection via string concat | Always use parameterized queries |
| Secrets in Docker layers | Multi-stage build, copy only artifacts |
| JWT validated client-side only | Always verify server-side with secret |
| CORS wildcard (*) in production | Explicit allowed origins list |
| Running containers as root | USER directive + read-only filesystem |
| Logging sensitive data | Sanitize logs, never log tokens/passwords |
| Outdated dependencies with CVEs | Automated audit in CI pipeline |

## Output Expectations
- Provide specific fixes with code, not just recommendations
- Flag severity (critical/high/medium/low)
- Prioritize: secrets > auth > injection > config > deps
