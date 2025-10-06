# Secure Desktop on Digital Ocean App Platform

This project provides a Dockerized environment for a secure remote desktop on Digital Ocean's App Platform. It includes a full Ubuntu desktop environment, accessible via VNC, with SSH access tunneled through stunnel to appear as regular HTTPS traffic.

## Features

- **Ubuntu Desktop:** A lightweight Xubuntu desktop environment
- **VNC Access:** Remote desktop access using any VNC client
- **SSH Access:** Secure shell access to the container
- **Stunnel VPN:** SSH traffic is tunneled through stunnel on port 443 to evade network restrictions
- **Persistent Storage:** A dedicated volume for your data that persists across container rebuilds
- **Easy Deployment:** Deployable on Digital Ocean's App Platform with a simple `app.yaml` configuration

## Prerequisites

- A [Digital Ocean account](https://cloud.digitalocean.com/registrations/new)
- A [GitHub account](https://github.com)
- Basic knowledge of Docker and containerization

## Quick Start

### 1. Repository Setup

1. Create a new GitHub repository
2. Upload all files from this project to your repository
3. Update the repository URL in `.do/app.yaml`:

```yaml
github:
  branch: main
  deploy_on_push: true
  repo: your-github-username/your-repo-name  # <-- Change this
```

### 2. Configure Credentials

Edit the `.do/app.yaml` file to set your own passwords:

```yaml
envs:
- key: SSH_PASSWORD
  value: "your-secure-password"     # <-- Change this
- key: VNC_PASSWORD
  value: "your-secure-vnc-password" # <-- Change this
```

**Default Credentials (change these!):**
- SSH Username: `appuser`
- SSH Password: `pWd123!@#`
- VNC Password: `vNc456$%^`

### 3. Deploy to Digital Ocean

1. Go to the "Apps" section in your Digital Ocean dashboard
2. Click "Create App"
3. Select your GitHub repository
4. Digital Ocean will automatically detect the `app.yaml` file
5. Choose a region and click "Create Resources"

## Accessing Your Services

### SSH Access (via stunnel)

The SSH service is tunneled through stunnel on port 443 to appear as HTTPS traffic. To connect:

1. **Install stunnel on your local machine:**
   ```bash
   # Ubuntu/Debian
   sudo apt-get install stunnel4
   
   # macOS
   brew install stunnel
   
   # Windows: Download from https://www.stunnel.org/
   ```

2. **Create a local stunnel configuration file** (`stunnel-client.conf`):
   ```
   client = yes
   [ssh]
   accept = 2222
   connect = your-app-url.ondigitalocean.app:443
   ```

3. **Start the stunnel client:**
   ```bash
   stunnel stunnel-client.conf
   ```

4. **Connect via SSH:**
   ```bash
   ssh appuser@localhost -p 2222
   ```

### VNC Access

1. **Install a VNC client:**
   - **Windows:** TightVNC, RealVNC, or UltraVNC
   - **macOS:** Built-in Screen Sharing or RealVNC
   - **Linux:** Remmina, TightVNC, or vinagre

2. **Connect to your desktop:**
   - **Host:** `your-app-url.ondigitalocean.app`
   - **Port:** `5900`
   - **Password:** Your configured VNC password

## File Structure

| File | Purpose |
|------|---------|
| `Dockerfile` | Container definition with all required services |
| `.do/app.yaml` | Digital Ocean App Platform specification |
| `stunnel.conf` | Stunnel configuration for port 443 tunneling |
| `supervisord.conf` | Process management for multiple services |
| `startup.sh` | Initialization script for passwords and services |
| `test_config.sh` | Configuration validation script |

## Persistent Storage

The `/data` directory inside the container is mounted as a persistent volume. Store your important files here to ensure they survive container rebuilds:

```bash
# Example: Save your work to persistent storage
cp important-file.txt /data/
```

## Troubleshooting

### Common Issues

1. **Cannot connect via SSH:**
   - Ensure stunnel is running on your local machine
   - Check that port 2222 is not already in use locally
   - Verify your app URL is correct

2. **VNC connection fails:**
   - Check that your VNC client supports the connection type
   - Verify the VNC password is correct
   - Try connecting without encryption first

3. **Desktop environment not starting:**
   - Check the application logs in Digital Ocean dashboard
   - The desktop may take 1-2 minutes to fully initialize

### Viewing Logs

In the Digital Ocean dashboard:
1. Go to your app
2. Click on the "Runtime Logs" tab
3. Look for credential information and error messages

### Testing Configuration

Run the included test script to validate your configuration:

```bash
./test_config.sh
```

## Security Considerations

- **Change default passwords** before deployment
- **Use strong passwords** for both SSH and VNC access
- **Regularly update** the container by rebuilding
- **Monitor access logs** through Digital Ocean dashboard
- **Consider IP restrictions** if accessing from fixed locations

## Cost Optimization

- Use the smallest instance size that meets your needs
- Monitor resource usage in the Digital Ocean dashboard
- Consider scaling down or pausing when not in use
- Adjust volume size based on actual storage needs

## Support

For issues specific to this setup, check the troubleshooting section above. For Digital Ocean App Platform issues, consult the [official documentation](https://docs.digitalocean.com/products/app-platform/).
