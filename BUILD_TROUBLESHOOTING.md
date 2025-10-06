# Build and Runtime Troubleshooting Guide

This guide addresses common build and runtime issues for the secure desktop Docker setup.

## Runtime Errors

### Error: "vncpasswd: command not found"

**Problem:** The `vncpasswd` command is not available in the container.

**Solution:** Updated startup scripts now use `x11vnc -storepasswd` instead:
```bash
# Old (broken)
echo "$VNC_PASSWORD" | vncpasswd -f > /home/appuser/.vnc/passwd

# New (fixed)
x11vnc -storepasswd "$VNC_PASSWORD" /home/appuser/.vnc/passwd
```

**Fixed in:** Both `startup.sh` and `startup-lightweight.sh`

### Error: "Readiness probe failed: dial tcp ... connect: connection refused"

**Problem:** Health check trying to connect to VNC port before service is ready.

**Solutions:**
1. **Increased startup time** in `.do/app.yaml`:
   ```yaml
   health_check:
     initial_delay_seconds: 120  # Increased from 60
     period_seconds: 30          # Increased from 10
     failure_threshold: 5        # Increased from 3
   ```

2. **Added service startup priorities** in `supervisord.conf`:
   ```ini
   [program:sshd]
   priority=100
   
   [program:stunnel]
   priority=200
   
   [program:x11vnc]
   priority=300
   startsecs=10
   ```

### Error: "component terminated with non-zero exit code: 127"

**Problem:** Missing dependencies or failed service startup.

**Debugging Steps:**
1. **Run debug script:**
   ```bash
   docker compose exec secure-desktop /debug_startup.sh
   ```

2. **Check service logs:**
   ```bash
   docker compose logs -f
   ```

3. **Verify package installation:**
   ```bash
   docker compose exec secure-desktop dpkg -l | grep -E "(x11vnc|openssh|stunnel)"
   ```

## Build Errors

### Error: "Unable to locate package xubuntu-desktop-minimal"

**Problem:** Package not available in Ubuntu repositories.

**Solution:** Updated Dockerfile to use available packages:
```dockerfile
# Fixed packages
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    x11vnc \
    tightvncserver \  # Provides vncpasswd alternative
    firefox \
    && apt-get clean
```

## Service Startup Issues

### VNC Server Not Starting

**Symptoms:**
- Connection refused on port 5900
- "x11vnc: cannot find display" in logs

**Solutions:**
1. **Verify X server is running:**
   ```bash
   docker compose exec secure-desktop ps aux | grep Xvfb
   ```

2. **Check X server display:**
   ```bash
   docker compose exec secure-desktop xdpyinfo -display :0
   ```

3. **Restart X11VNC service:**
   ```bash
   docker compose exec secure-desktop supervisorctl restart x11vnc
   ```

### SSH Server Not Starting

**Symptoms:**
- Connection refused on port 2222
- "sshd: no hostkeys available" in logs

**Solutions:**
1. **Generate SSH host keys:**
   ```bash
   docker compose exec secure-desktop ssh-keygen -A
   ```

2. **Restart SSH service:**
   ```bash
   docker compose exec secure-desktop supervisorctl restart sshd
   ```

### Stunnel Not Starting

**Symptoms:**
- Connection refused on port 8443
- Certificate errors in logs

**Solutions:**
1. **Verify certificate exists:**
   ```bash
   docker compose exec secure-desktop ls -la /etc/ssl/certs/stunnel.pem
   ```

2. **Test stunnel config:**
   ```bash
   docker compose exec secure-desktop stunnel -test -fd 0 < /etc/stunnel/stunnel.conf
   ```

## Digital Ocean Specific Issues

### App Platform Health Check Failures

**Problem:** Health checks failing during startup.

**Solution:** Updated health check configuration:
```yaml
health_check:
  http_path: /
  initial_delay_seconds: 120    # Allow more time for startup
  period_seconds: 30            # Check less frequently
  timeout_seconds: 10           # Allow more time per check
  success_threshold: 1
  failure_threshold: 5          # Allow more failures
```

### Resource Constraints

**Problem:** Container running out of memory or CPU.

**Solutions:**
1. **Use lightweight version:**
   ```bash
   mv Dockerfile Dockerfile.full
   mv Dockerfile.lightweight Dockerfile
   ```

2. **Increase instance size in `.do/app.yaml`:**
   ```yaml
   instance_size_slug: basic-m  # or basic-l
   ```

## Debugging Tools

### Debug Startup Script

Run the comprehensive debug script:
```bash
# In running container
./debug_startup.sh

# Or via Docker Compose
docker compose exec secure-desktop ./debug_startup.sh
```

### Manual Service Testing

Test each service individually:
```bash
# Test SSH
ssh appuser@localhost -p 2222

# Test VNC (with VNC client)
vncviewer localhost:5900

# Test Stunnel
telnet localhost 8443
```

### Log Analysis

Check specific service logs:
```bash
# All logs
docker compose logs -f

# Specific service logs
docker compose exec secure-desktop tail -f /var/log/sshd.log
docker compose exec secure-desktop tail -f /var/log/x11vnc.log
docker compose exec secure-desktop tail -f /var/log/stunnel.log
docker compose exec secure-desktop tail -f /var/log/supervisord.log
```

## Performance Optimization

### Reduce Startup Time

1. **Use lightweight version** for faster startup
2. **Pre-build images** and push to registry
3. **Optimize package installation** order

### Memory Usage

1. **Monitor resource usage:**
   ```bash
   docker stats secure-desktop-local
   ```

2. **Adjust X server settings:**
   ```bash
   # Reduce color depth
   Xvfb :0 -screen 0 1024x768x16  # 16-bit instead of 24-bit
   ```

## Recovery Procedures

### Complete Service Restart

```bash
# Stop all services
docker compose down

# Remove containers and volumes (if needed)
docker compose down -v

# Rebuild and start
docker compose up -d --build
```

### Partial Service Restart

```bash
# Restart specific services
docker compose exec secure-desktop supervisorctl restart all
docker compose exec secure-desktop supervisorctl restart x11vnc
docker compose exec secure-desktop supervisorctl restart sshd
```

## Prevention

### Regular Maintenance

1. **Update base images** regularly
2. **Monitor logs** for warnings
3. **Test connectivity** after deployments
4. **Backup persistent data** from `/data` volume

### Monitoring

Set up monitoring for:
- Service availability (SSH, VNC, Stunnel)
- Resource usage (CPU, memory, disk)
- Log errors and warnings
- Connection success rates

The fixes implemented should resolve the `vncpasswd` command not found error and improve service startup reliability.
