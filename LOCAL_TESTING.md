# Local Testing Guide

This guide helps you test the secure desktop setup locally using Docker Compose before deploying to Digital Ocean.

## Prerequisites

- Docker and Docker Compose installed
- At least 2GB RAM available for the container
- Ports 2222, 5900, and 8443 available on your host

## Quick Start

1. **Start the services:**
   ```bash
   docker compose up -d --build
   ```

2. **Check container status:**
   ```bash
   docker compose ps
   ```

3. **View logs:**
   ```bash
   docker compose logs -f
   ```

## Testing Connections

### SSH Connection Test

**Method 1: Direct SSH (Recommended for testing)**
```bash
ssh appuser@localhost -p 2222
```
- Password: `testpass123`

**Method 2: Via Stunnel (Production-like)**
1. Install stunnel on your host
2. Create `stunnel-local.conf`:
   ```
   client = yes
   [ssh]
   accept = 2223
   connect = localhost:8443
   ```
3. Run stunnel: `stunnel stunnel-local.conf`
4. Connect: `ssh appuser@localhost -p 2223`

### VNC Connection Test

**Using VNC Client:**
- **Host:** `localhost`
- **Port:** `5900`
- **Password:** `vncpass123`

**Command line test (if vncviewer installed):**
```bash
vncviewer localhost:5900
```

### Port Connectivity Test

**Test SSH port:**
```bash
telnet localhost 2222
# Should show SSH banner
```

**Test VNC port:**
```bash
telnet localhost 5900
# Should connect (may show binary data)
```

**Test Stunnel port:**
```bash
telnet localhost 8443
# Should connect to stunnel
```

## Automated Testing

Run the included test script:
```bash
./test_ports.sh
```

This validates:
- Port mappings configuration
- Environment variables
- Required configuration files
- Service dependencies

## Container Management

### View running processes inside container:
```bash
docker compose exec secure-desktop ps aux
```

### Access container shell:
```bash
docker compose exec secure-desktop bash
```

### Check service status:
```bash
docker compose exec secure-desktop supervisorctl status
```

### View individual service logs:
```bash
# SSH logs
docker compose exec secure-desktop tail -f /var/log/sshd.log

# VNC logs  
docker compose exec secure-desktop tail -f /var/log/x11vnc.log

# Stunnel logs
docker compose exec secure-desktop tail -f /var/log/stunnel.log
```

## Troubleshooting

### Container won't start
1. Check Docker daemon is running
2. Ensure ports are not already in use:
   ```bash
   netstat -tulpn | grep -E '(2222|5900|8443)'
   ```
3. Check Docker logs:
   ```bash
   docker compose logs
   ```

### SSH connection refused
1. Wait 30-60 seconds for services to fully start
2. Check SSH service status:
   ```bash
   docker compose exec secure-desktop supervisorctl status sshd
   ```
3. Verify SSH is listening:
   ```bash
   docker compose exec secure-desktop netstat -tulpn | grep :22
   ```

### VNC connection fails
1. Check X server is running:
   ```bash
   docker compose exec secure-desktop ps aux | grep Xvfb
   ```
2. Verify VNC service:
   ```bash
   docker compose exec secure-desktop supervisorctl status x11vnc
   ```
3. Test VNC password:
   ```bash
   docker compose exec secure-desktop cat /etc/vnc_password | wc -c
   # Should show 8 (password length)
   ```

### Desktop environment issues
1. Check if desktop process is running:
   ```bash
   docker compose exec secure-desktop ps aux | grep xfce
   ```
2. Restart desktop service:
   ```bash
   docker compose exec secure-desktop supervisorctl restart all
   ```

## Performance Monitoring

### Resource usage:
```bash
docker stats secure-desktop-local
```

### Container disk usage:
```bash
docker compose exec secure-desktop df -h
```

### Memory usage inside container:
```bash
docker compose exec secure-desktop free -h
```

## Data Persistence

Your data is stored in the `desktop_data` Docker volume:

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect digitalocean_app_desktop_data

# Backup volume
docker run --rm -v digitalocean_app_desktop_data:/data -v $(pwd):/backup ubuntu tar czf /backup/desktop_backup.tar.gz -C /data .

# Restore volume
docker run --rm -v digitalocean_app_desktop_data:/data -v $(pwd):/backup ubuntu tar xzf /backup/desktop_backup.tar.gz -C /data
```

## Cleanup

### Stop and remove containers:
```bash
docker compose down
```

### Remove containers and volumes:
```bash
docker compose down -v
```

### Remove images:
```bash
docker rmi digitalocean_app-secure-desktop
```

## Expected Test Results

When everything is working correctly:

✅ **SSH Test:** Should connect and show Ubuntu shell prompt  
✅ **VNC Test:** Should show Xubuntu desktop environment  
✅ **Stunnel Test:** Should accept connections on port 8443  
✅ **Persistence Test:** Files in `/data` should survive container restarts  

## Next Steps

Once local testing is successful:
1. Push your code to GitHub
2. Update `.do/app.yaml` with your repository details
3. Deploy to Digital Ocean App Platform
4. Test the production deployment using the same methods
