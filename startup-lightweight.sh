#!/bin/bash
set -e

# Set default passwords if environment variables are not provided
SSH_PASSWORD=${SSH_PASSWORD:-$(pwgen -s 12 1)}
VNC_PASSWORD=${VNC_PASSWORD:-$(pwgen -s 8 1)}

# Set the SSH password for appuser
echo "appuser:$SSH_PASSWORD" | chpasswd

# Create VNC password using x11vnc method
mkdir -p /home/appuser/.vnc
chown -R appuser:appuser /home/appuser/.vnc

# Create VNC password file using x11vnc
x11vnc -storepasswd "$VNC_PASSWORD" /home/appuser/.vnc/passwd
chmod 600 /home/appuser/.vnc/passwd
chown appuser:appuser /home/appuser/.vnc/passwd

# Also create a system-wide VNC password file
x11vnc -storepasswd "$VNC_PASSWORD" /etc/vnc_password
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
sleep 5

# Test if X server is running
if ! xdpyinfo -display :0 >/dev/null 2>&1; then
    echo "ERROR: X server failed to start"
    exit 1
fi

# Start lightweight window manager as appuser
echo "Starting window manager..."
su - appuser -c "DISPLAY=:0 fluxbox" &

# Start a terminal for the user
su - appuser -c "DISPLAY=:0 xterm" &

# Wait for desktop to initialize
sleep 5

# Start supervisord to manage services
echo "Starting services..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
