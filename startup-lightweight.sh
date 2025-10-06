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

# Print credentials to logs
echo "=== CREDENTIALS ==="
echo "SSH User: appuser"
echo "SSH Password: $SSH_PASSWORD"
echo "VNC Password: $VNC_PASSWORD"
echo "=================="

# Create log directory
mkdir -p /var/log

# Set up display
export DISPLAY=:0

# Start X server in background
echo "Starting X server..."
Xvfb :0 -screen 0 1024x768x24 -ac &

# Wait for X server to start
sleep 3

# Start lightweight window manager as appuser
echo "Starting window manager..."
su - appuser -c "DISPLAY=:0 fluxbox" &

# Start a terminal for the user
su - appuser -c "DISPLAY=:0 xterm" &

# Wait a bit for desktop to initialize
sleep 3

# Start supervisord to manage services
echo "Starting services..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
