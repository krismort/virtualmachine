#!/bin/bash
set -e

# Set default passwords if environment variables are not provided
SSH_PASSWORD=${SSH_PASSWORD:-$(pwgen -s 12 1)}
VNC_PASSWORD=${VNC_PASSWORD:-$(pwgen -s 8 1)}

# Set the SSH password for appuser
echo "appuser:$SSH_PASSWORD" | chpasswd

# Set the VNC password
mkdir -p /home/appuser/.vnc
echo "$VNC_PASSWORD" | vncpasswd -f > /home/appuser/.vnc/passwd
chmod 600 /home/appuser/.vnc/passwd
chown -R appuser:appuser /home/appuser/.vnc

# Also create a system-wide VNC password file
echo "$VNC_PASSWORD" | vncpasswd -f > /etc/vnc_password
chmod 600 /etc/vnc_password

# Print credentials to logs (for debugging - remove in production)
echo "=== CREDENTIALS ==="
echo "SSH User: appuser"
echo "SSH Password: $SSH_PASSWORD"
echo "VNC Password: $VNC_PASSWORD"
echo "=================="

# Create log directory
mkdir -p /var/log

# Start X server in background
echo "Starting X server..."
Xvfb :0 -screen 0 1024x768x24 -ac &
export DISPLAY=:0

# Wait for X server to start
sleep 3

# Start desktop environment as appuser
echo "Starting desktop environment..."
su - appuser -c "DISPLAY=:0 startxfce4" &

# Wait a bit for desktop to initialize
sleep 5

# Start supervisord to manage services
echo "Starting services..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
