# Build Troubleshooting Guide

This guide addresses common build issues and provides solutions for the secure desktop Docker setup.

## Common Build Errors

### Error: "Unable to locate package xubuntu-desktop-minimal"

**Problem:** The package `xubuntu-desktop-minimal` may not be available in all Ubuntu repositories.

**Solution:** The main `Dockerfile` has been updated to use `xfce4` and `xfce4-goodies` instead, which are more widely available.

**Fixed in:** Main `Dockerfile` now uses:
```dockerfile
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    x11vnc \
    firefox \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
```

### Alternative: Lightweight Build

If you encounter issues with the full desktop environment, use the lightweight version:

**Files:**
- `Dockerfile.lightweight` - Minimal desktop with Fluxbox
- `startup-lightweight.sh` - Lightweight startup script
- `docker-compose.lightweight.yml` - Compose file for lightweight version

**To use lightweight version:**
```bash
# Build lightweight version
docker compose -f docker-compose.lightweight.yml up -d --build

# Or rename files to use as default
mv Dockerfile Dockerfile.full
mv Dockerfile.lightweight Dockerfile
```

## Build Options Comparison

| Feature | Full Version | Lightweight Version |
|---------|-------------|-------------------|
| Desktop Environment | XFCE4 (full) | Fluxbox (minimal) |
| Applications | Firefox, full suite | xterm only |
| Build Time | ~10-15 minutes | ~3-5 minutes |
| Image Size | ~2-3 GB | ~800 MB - 1 GB |
| RAM Usage | ~1-2 GB | ~300-500 MB |

## Build Performance Tips

### 1. Use Multi-stage Builds
The Dockerfiles are already optimized with staged package installation to avoid timeouts.

### 2. Increase Build Resources
If building locally, ensure Docker has sufficient resources:
```bash
# Check Docker resources
docker system df
docker system info
```

### 3. Use Build Cache
Docker will cache layers. To force rebuild:
```bash
docker compose build --no-cache
```

### 4. Regional Package Mirrors
For faster package downloads, you can modify the Dockerfile to use regional mirrors:
```dockerfile
# Add before first apt-get update
RUN sed -i 's/archive.ubuntu.com/your-regional-mirror.com/g' /etc/apt/sources.list
```

## Digital Ocean Specific Issues

### Build Timeout
Digital Ocean App Platform has build time limits. If builds timeout:

1. **Use the lightweight version**
2. **Optimize package installation:**
   ```dockerfile
   # Install in smaller groups
   RUN apt-get update && apt-get install -y openssh-server stunnel4
   RUN apt-get install -y supervisor pwgen openssl
   RUN apt-get install -y xfce4 x11vnc
   ```

### Resource Limits
Ensure your Digital Ocean app has sufficient resources:
- **Minimum:** basic-s (1 vCPU, 512 MB RAM)
- **Recommended:** basic-m (1 vCPU, 1 GB RAM)

## Testing Build Locally

### Quick Test Build
```bash
# Test lightweight version first
docker build -f Dockerfile.lightweight -t test-light .

# If successful, test full version
docker build -f Dockerfile -t test-full .
```

### Debugging Build Issues
```bash
# Build with verbose output
docker build --progress=plain -f Dockerfile .

# Build specific stage only
docker build --target stage-name -f Dockerfile .
```

## Package Alternatives

If specific packages fail to install, here are alternatives:

| Original Package | Alternative | Notes |
|-----------------|-------------|-------|
| `xubuntu-desktop-minimal` | `xfce4` + `xfce4-goodies` | More widely available |
| `xubuntu-desktop` | `lubuntu-desktop` | Lighter alternative |
| `firefox` | `chromium-browser` | Alternative browser |
| `x11vnc` | `tightvncserver` | Alternative VNC server |

## Environment-Specific Fixes

### Ubuntu 20.04 Base
If you need Ubuntu 20.04 compatibility:
```dockerfile
FROM ubuntu:20.04
# Add universe repository
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository universe
```

### ARM64 Support
For ARM64 platforms (Apple Silicon, etc.):
```dockerfile
FROM --platform=linux/amd64 ubuntu:22.04
# Forces x86_64 build on ARM systems
```

## Verification Steps

After fixing build issues:

1. **Run configuration tests:**
   ```bash
   ./test_config.sh
   ```

2. **Test port mappings:**
   ```bash
   ./test_ports.sh
   ```

3. **Verify services start:**
   ```bash
   docker compose logs -f
   ```

## Getting Help

If you continue to experience build issues:

1. Check the build logs for specific error messages
2. Try the lightweight version first
3. Ensure your Docker environment has sufficient resources
4. Consider using a different base image if needed

The lightweight version should build successfully in most environments and provides the core functionality needed for the secure desktop setup.
